# frozen_string_literal: true

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
  def initialize(rule_directory: nil,
                 allow_suppression: true,
                 print_suppression: false,
                 isolate_custom_rule_exceptions: false)
    @rule_directory = rule_directory
    @allow_suppression = allow_suppression
    @print_suppression = print_suppression
    @isolate_custom_rule_exceptions = isolate_custom_rule_exceptions
    validate_extra_rule_directory rule_directory
  end

  def rule_definitions
    rule_registry = RuleRegistry.new

    discover_rule_classes(@rule_directory).each do |rule_class|
      rule_registry
        .definition(**rule_registry_from_rule_class(rule_class))
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
    if Logging.logger['log'].debug?
      Logging.logger['log'].debug "cfn_model: #{cfn_model}"
    end

    violations = []

    validate_cfn_nag_metadata(cfn_model)

    filter_rule_classes cfn_model, violations

    filter_jmespath_filenames cfn_model, violations

    violations
  end

  private

  def rule_registry_from_rule_class(rule_class)
    rule = rule_class.new
    { id: rule.rule_id,
      type: rule.rule_type,
      message: rule.rule_text }
  end

  def filter_jmespath_filenames(cfn_model, violations)
    discover_jmespath_filenames(@rule_directory).each do |jmespath_file|
      evaluator = JmesPathEvaluator.new cfn_model
      evaluator.instance_eval do
        eval IO.read jmespath_file
      end
      violations += evaluator.violations
    end
  end

  def filter_rule_classes(cfn_model, violations)
    discover_rule_classes(@rule_directory).each do |rule_class|
      begin
        filtered_cfn_model = cfn_model_with_suppressed_resources_removed cfn_model: cfn_model,
                                                                         rule_id: rule_class.new.rule_id,
                                                                         allow_suppression: @allow_suppression
        audit_result = rule_class.new.audit(filtered_cfn_model)
        violations << audit_result unless audit_result.nil?
      rescue Exception => exception
        raise exception unless @isolate_custom_rule_exceptions
        STDERR.puts exception
      end
    end
  end

  def rules_to_suppress(resource)
    if resource.metadata &&
       resource.metadata['cfn_nag'] &&
       resource.metadata['cfn_nag']['rules_to_suppress']

      resource.metadata['cfn_nag']['rules_to_suppress']
    end
  end

  # XXX given mangled_metadatas is never used or returned,
  # STDERR emit can be moved to unless block
  def validate_cfn_nag_metadata(cfn_model)
    mangled_metadatas = []
    cfn_model.resources.each do |logical_resource_id, resource|
      resource_rules_to_suppress = rules_to_suppress resource
      next if resource_rules_to_suppress.nil?
      mangled_rules = resource_rules_to_suppress.select do |rule_to_suppress|
        rule_to_suppress['id'].nil?
      end
      unless mangled_rules.empty?
        mangled_metadatas << [logical_resource_id, mangled_rules]
      end
    end
    mangled_metadatas.each do |mangled_metadata|
      logical_resource_id = mangled_metadata.first
      mangled_rules = mangled_metadata[1]

      STDERR.puts "#{logical_resource_id} has missing cfn_nag suppression rule id: #{mangled_rules}"
    end
  end

  def suppress_resource?(rules_to_suppress, rule_id, logical_resource_id)
    found_suppression_rule = rules_to_suppress.find do |rule_to_suppress|
      next if rule_to_suppress['id'].nil?
      rule_to_suppress['id'] == rule_id
    end
    if found_suppression_rule && @print_suppression
      STDERR.puts "Suppressing #{rule_id} on #{logical_resource_id} for reason: #{found_suppression_rule['reason']}"
    end
    !found_suppression_rule.nil?
  end

  def cfn_model_with_suppressed_resources_removed(cfn_model:,
                                                  rule_id:,
                                                  allow_suppression:)
    return cfn_model unless allow_suppression

    cfn_model = cfn_model.copy

    cfn_model.resources.delete_if do |logical_resource_id, resource|
      rules_to_suppress = rules_to_suppress resource
      if rules_to_suppress.nil?
        false
      else
        suppress_resource?(rules_to_suppress, rule_id, logical_resource_id)
      end
    end
    cfn_model
  end

  def validate_extra_rule_directory(rule_directory)
    return true if rule_directory.nil? || File.directory?(rule_directory)
    raise "Not a real directory #{rule_directory}"
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
    rule_filenames += Dir[File.join(__dir__,
                                    'custom_rules',
                                    '*jmespath.rb')].sort
    Logging.logger['log'].debug "jmespath_filenames: #{rule_filenames}"
    rule_filenames
  end
end
