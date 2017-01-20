require_relative 'rule'
require_relative 'custom_rules/security_group_missing_egress'
require_relative 'custom_rules/user_missing_group'
require_relative 'model/cfn_model'
require_relative 'result_view/simple_stdout_results'
require_relative 'result_view/json_results'
require_relative 'custom_rules/unencrypted_s3_put_allowed'
require 'tempfile'

class CfnNag
  include Rule

  def initialize
    @warning_registry = []
    @violation_registry = []
  end

  def dump_rules
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
      audit_file(input_json_path: dummy_cfn_template.path)
    end

    custom_rule_registry.each do |rule_class|
      @violation_registry << rule_class.new.rule_text
    end

    puts 'WARNING VIOLATIONS:'
    puts @warning_registry.sort
    puts
    puts 'FAILING VIOLATIONS:'
    puts @violation_registry.sort
  end

  def audit(input_json_path:,
            output_format:'txt')

    aggregate_results = audit_results input_json_path: input_json_path,
                                      output_format: output_format

    aggregate_results.inject(0) { |total_failure_count, results| total_failure_count + results[:file_results][:failure_count] }
  end

  def audit_results(input_json_path:,
                    output_format:'txt')

    templates = discover_templates(input_json_path)

    aggregate_results = []
    templates.each do |template|
      aggregate_results << {
          filename: template,
          file_results: audit_file(input_json_path: template)
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

  def audit_template(input_json:)
    @stop_processing = false
    @violations = []

    unless legal_json?(input_json)
      @violations << Violation.new(type: Violation::FAILING_VIOLATION,
                                   message: 'not even legit JSON',
                                   violating_code: input_json)
      @stop_processing = true
    end

    generic_json_rules input_json unless @stop_processing == true

    custom_rules input_json unless @stop_processing == true

    {
      failure_count: Rule::count_failures(@violations),
      violations: @violations
    }
  end

  private

  def render_results(aggregate_results:,output_format:)
    results_renderer(output_format).new.render(aggregate_results)
  end

  def audit_file(input_json_path:)
    audit_template(input_json: IO.read(input_json_path))
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

  def generic_json_rules(input_json)
    unless command? 'jq'
      fail 'jq executable must be available in PATH'
    end

    $STDERR.puts "DIR: #{__dir__}"
    Dir[File.join(__dir__, 'json_rules', '*.rb')].sort.each do |rule_file|
      @input_json = input_json
      eval IO.read(rule_file)
    end
  end

  def custom_rules(input_json)
    cfn_model = CfnModel.new.parse(input_json)
    custom_rule_registry.each do |rule_class|
      audit_result = rule_class.new.audit(cfn_model)
      @violations << audit_result unless audit_result.nil?
    end
  end

  def custom_rule_registry
    [
      SecurityGroupMissingEgressRule,
      UserMissingGroupRule,
      UnencryptedS3PutObjectAllowedRule
    ]
  end
end
