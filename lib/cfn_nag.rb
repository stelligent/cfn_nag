require_relative 'rule'
require_relative 'custom_rules/security_group_missing_egress'
require_relative 'model/cfn_model'

class CfnNag
  include Rule

  def audit(input_json_path)
    fail 'not even legit JSON' unless legal_json?(input_json_path)

    @failure_count = 0
    @warning_count = 0

    generic_json_rules input_json_path

    custom_rules

    puts "failure_count: #{@failure_count}"
    puts "warning_count: #{@warning_count}"
    @failure_count
  end

  private

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
      puts rule_file
      @input_json_path = input_json_path
      eval IO.read(rule_file)
    end
  end

  def custom_rules
    cfn_model = CfnModel.new.parse(IO.read(@input_json_path))
    rules = [
      SecurityGroupMissingEgressRule
    ]
    rules.each do |rule_class|
      @failure_count += 1 unless rule_class.new.audit(cfn_model)
    end
  end
end
