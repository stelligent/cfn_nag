require 'cfn-model'
require 'logging'
require_relative 'rule_registry'
require 'cfn-nag/jmes_path_evaluator'
require 'cfn-nag/jmes_path_discovery'

##
# This object can discover the internal and custom user-provided rules and
# apply these rules to a CfnModel object
#
class CustomRuleLoader
  def initialize(rule_directory: nil)
    @rule_directory = rule_directory
    validate_extra_rule_directory rule_directory
  end

  def rule_definitions
    rule_registry = RuleRegistry.new

    discover_rule_classes(@rule_directory).each do |rule_class|
      rule = rule_class.new
      rule_registry.definition(id: rule.rule_id,
                               type: rule.rule_type,
                               message: rule.rule_text)
    end

    discover_jmespath_filenames(@rule_directory).each do |jmespath_file|
      evaluator = JmesPathDiscovery.new rule_registry
      evaluator.instance_eval do
        eval IO.read jmespath_file
      end
    end

    rule_registry
  end

  def execute_custom_rules(cfn_model)
    Logging.logger['log'].debug "cfn_model: #{cfn_model}"

    violations = []

    discover_rule_classes(@rule_directory).each do |rule_class|
      audit_result = rule_class.new.audit(cfn_model)
      violations << audit_result unless audit_result.nil?
    end

    discover_jmespath_filenames(@rule_directory).each do |jmespath_file|
      evaluator = JmesPathEvaluator.new cfn_model
      evaluator.instance_eval do
        eval IO.read jmespath_file
      end
      violations +=  evaluator.violations
    end
    violations
  end

  private

  def validate_extra_rule_directory(rule_directory)
    unless rule_directory.nil?
      fail "Not a real directory #{rule_directory}" unless File.directory? rule_directory
    end
  end

  def discover_rule_filenames(rule_directory)
    rule_filenames = []
    unless rule_directory.nil?
      rule_filenames += Dir[File.join(rule_directory, '*Rule.rb')].sort
    end
    rule_filenames += Dir[File.join(__dir__, 'custom_rules', '*Rule.rb')].sort
    Logging.logger['log'].debug "rule_filenames: #{rule_filenames}"
    rule_filenames
  end

  def discover_rule_classes(rule_directory)
    rule_classes = []

    rule_filenames = discover_rule_filenames(rule_directory)

    rule_filenames.each do |rule_filename|
      require(rule_filename)
      rule_classname = File.basename(rule_filename, '.rb')

      rule_classes << Object.const_get(rule_classname)
    end
    Logging.logger['log'].debug "rule_classes: #{rule_classes}"

    rule_classes
  end

  def discover_jmespath_filenames(rule_directory)
    rule_filenames = []
    unless rule_directory.nil?
      rule_filenames += Dir[File.join(rule_directory, '*jmespath.rb')].sort
    end
    rule_filenames += Dir[File.join(__dir__, 'custom_rules', '*jmespath.rb')].sort
    Logging.logger['log'].debug "jmespath_filenames: #{rule_filenames}"
    rule_filenames
  end
end