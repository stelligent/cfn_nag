require_relative 'rule'
require_relative 'custom_rules/security_group_missing_egress'
require_relative 'custom_rules/user_missing_group'
require_relative 'model/cfn_model'
require_relative 'result_view/simple_stdout_results'
require_relative 'result_view/json_results'

class CfnNag
  include Rule

  def audit(input_json_path:,
            output_format:'txt')

    templates = discover_templates(input_json_path)

    aggregate_results = []
    templates.each do |template|
      aggregate_results << {
        filename: template,
        file_results: audit_file(input_json_path: template)
      }
    end

    results_renderer(output_format).new.render(aggregate_results)

    aggregate_results.inject(0) { |total_failure_count, results| total_failure_count + results[:file_results][:failure_count] }
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

  private

  def audit_file(input_json_path:)
    fail 'not even legit JSON' unless legal_json?(input_json_path)
    @stop_processing = false
    @violations = []

    generic_json_rules input_json_path

    custom_rules input_json_path unless @stop_processing == true

    {
      failure_count: Rule::count_failures(@violations),
      violations: @violations
    }
  end

  def discover_templates(input_json_path)
    if ::File.directory? input_json_path
      templates = find_templates_in_directory(directory: input_json_path)
    elsif ::File.file? input_json_path
      templates = [input_json_path]
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

  def legal_json?(input_json_path)
    begin
      JSON.parse(IO.read(input_json_path))
      true
    rescue JSON::ParserError
      return false
    end
  end

  def command?(command)
    system("which #{command} > /dev/null 2>&1")
  end

  def generic_json_rules(input_json_path)
    unless command? 'jq'
      fail 'jq executable must be available in PATH'
    end

    Dir[File.join(__dir__, 'json_rules', '*.rb')].sort.each do |rule_file|
      @input_json_path = input_json_path
      eval IO.read(rule_file)
    end
  end

  def custom_rules(input_json_path)
    cfn_model = CfnModel.new.parse(IO.read(input_json_path))
    rules = [
      SecurityGroupMissingEgressRule,
      UserMissingGroupRule
    ]
    rules.each do |rule_class|
      audit_result = rule_class.new.audit(cfn_model)
      @violations << audit_result unless audit_result.nil?
    end
  end
end
