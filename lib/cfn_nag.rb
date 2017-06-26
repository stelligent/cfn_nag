require_relative 'rule'
require_relative 'custom_rule_loader'
require_relative 'rule_registry'
require_relative 'profile_loader'
require_relative 'model/cfn_model'
require_relative 'result_view/simple_stdout_results'
require_relative 'result_view/json_results'
require_relative 'result_view/rules_view'
require 'tempfile'

class CfnNag
  include Rule

  def initialize(profile_definition: nil)
    @warning_registry = []
    @violation_registry = []
    @rule_registry = RuleRegistry.new
    @custom_rule_loader = CustomRuleLoader.new(@rule_registry)
    @profile_definition = profile_definition
  end

  def dump_rules(rule_directories: [])
    validate_extra_rule_directories(rule_directories)

    dummy_cfn = <<-END
      {
        "Resources": {
          "resource1": {
            "Type" : "AWS::EC2::DHCPOptions",
            "Properties": {
              "DomainNameServers" : [ "10.0.0.1" ]
            }
          }
        }
      }
    END

    Tempfile.open('tempfile') do |dummy_cfn_template|
      dummy_cfn_template.write dummy_cfn
      dummy_cfn_template.rewind
      audit_file(input_json_path: dummy_cfn_template.path,
                 rule_directories: rule_directories)
    end

    profile = nil
    unless @profile_definition.nil?
      profile = ProfileLoader.new(@rule_registry).load(profile_definition: @profile_definition)
    end

    RulesView.new.emit(@rule_registry, profile)
  end

  def audit(input_json_path:,
            rule_directories: [],
            output_format:'txt')
    validate_extra_rule_directories(rule_directories)

    aggregate_results = audit_results input_json_path: input_json_path,
                                      output_format: output_format,
                                      rule_directories: rule_directories.flatten

    aggregate_results.inject(0) { |total_failure_count, results| total_failure_count + results[:file_results][:failure_count] }
  end

  def audit_results(input_json_path:,
                    output_format:'txt',
                    rule_directories: [])

    templates = discover_templates(input_json_path)

    aggregate_results = []
    templates.each do |template|
      aggregate_results << {
          filename: template,
          file_results: audit_file(input_json_path: template,
                                   rule_directories: rule_directories)
      }
    end

    render_results(aggregate_results: aggregate_results,
                   output_format: output_format)

    aggregate_results
  end

  def self.configure_logging(opts)
    logger = Logging.logger['log']
    if opts[:debug]
      logger.level = :debug
    else
      logger.level = :info
    end

    logger.add_appenders Logging.appenders.stdout
  end

  def audit_template(input_json:,
                     rule_directories: [])
    @stop_processing = false
    @violations = []

    unless legal_json?(input_json)
      @violations << Violation.new(id: 'FATAL',
                                   type: Violation::FAILING_VIOLATION,
                                   message: 'not even legit JSON',
                                   violating_code: input_json)
      @stop_processing = true
    end

    generic_json_rules(input_json, rule_directories) unless @stop_processing == true

    @violations += custom_rules input_json unless @stop_processing == true

    @violations = filter_violations_by_profile @violations unless @stop_processing == true

    {
      failure_count: Rule::count_failures(@violations),
      violations: @violations
    }
  end

  private

  def filter_violations_by_profile(violations)
    profile = nil
    unless @profile_definition.nil?
      profile = ProfileLoader.new(@rule_registry).load(profile_definition: @profile_definition)
    end

    violations.reject do |violation|
      not profile.nil? and not profile.execute_rule?(violation.id)
    end
  end

  def validate_extra_rule_directories(rule_directories)
    rule_directories.flatten.each do |rule_directory|
      fail "Not a real directory #{rule_directory}" unless File.directory? rule_directory
    end
  end


  def render_results(aggregate_results:,
                     output_format:)
    results_renderer(output_format).new.render(aggregate_results)
  end

  def audit_file(input_json_path:,
                 rule_directories:)
    audit_template(input_json: IO.read(input_json_path),
                   rule_directories: rule_directories)
  end

  def discover_templates(input_json_path)
    if ::File.directory? input_json_path
      templates = find_templates_in_directory(directory: input_json_path)
    elsif ::File.file? input_json_path
      templates = [input_json_path.path]
    else
      fail "#{input_json_path} is not a proper path"
    end
    templates
  end

  def find_templates_in_directory(directory:,
                                  cfn_extensions: %w(json template))

    templates = []
    cfn_extensions.each do |cfn_extension|
      templates += Dir[File.join(directory, "**/*.#{cfn_extension}")]
    end
    templates
  end

  def results_renderer(output_format)
    registry = {
      'txt' => SimpleStdoutResults,
      'json' => JsonResults
    }
    registry[output_format]
  end

  def legal_json?(input_json)
    begin
      JSON.parse(input_json)
      true
    rescue JSON::ParserError
      return false
    end
  end

  def command?(command)
    not system("#{command} > /dev/null 2>&1").nil?
  end

  def generic_json_rules(input_json, rule_directories)
    unless command? 'jq'
      fail 'jq executable must be available in PATH'
    end
    rules = Dir[File.join(__dir__, 'json_rules', '*.rb')].sort

    rules.each do |rule_file|
      @input_json = input_json
      eval IO.read(rule_file)
    end

    rule_directories.each do |rule_directory|
      rules = Dir[File.join(rule_directory, '*.rb')].sort

      if rules.length > 0
        rules.each do |rule_file|
          @input_json = input_json
          eval IO.read(rule_file)
        end
      end
    end
  end

  def custom_rules(input_json)
    @custom_rule_loader.custom_rules(input_json)
  end
end
