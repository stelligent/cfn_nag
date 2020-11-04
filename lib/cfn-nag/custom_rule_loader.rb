# frozen_string_literal: true

require 'cfn-model'
require 'logging'
require_relative 'rule_registry'
require_relative 'rule_repos/file_based_rule_repo'
require_relative 'rule_repos/gem_based_rule_repo'
require_relative 'rule_repos/s3_based_rule_repo'
require_relative 'rule_repository_loader'
require_relative 'metadata'

##
# This object can discover the internal and custom user-provided rules and
# apply these rules to a CfnModel object
#
class CustomRuleLoader
  include Metadata

  # k,v for injection into rules that can respond to k
  @rule_arguments = {}

  class << self
    attr_accessor :rule_arguments
  end

  def initialize(rule_directory: nil,
                 allow_suppression: true,
                 print_suppression: false,
                 isolate_custom_rule_exceptions: false,
                 rule_repository_definitions: [])
    @rule_directory = rule_directory
    @allow_suppression = allow_suppression
    @print_suppression = print_suppression
    @isolate_custom_rule_exceptions = isolate_custom_rule_exceptions
    @rule_repository_definitions = rule_repository_definitions
    @registry = nil
  end

  ##
  # the first time this runs, it's "expensive".  the core rules, the gem-based rules will load, and
  # any other repos like "s3" will go the expensive route.  after that, it's cached so you can
  # call it as many times as you like unless you force_refresh
  #
  def rule_definitions(force_refresh: false)
    if @registry.nil? || force_refresh
      @registry = FileBasedRuleRepo.new(@rule_directory).discover_rules
      @registry.merge! GemBasedRuleRepo.new.discover_rules

      @registry = RuleRepositoryLoader.new.merge(@registry, @rule_repository_definitions)
      @registry
    end
    @registry
  end

  def execute_custom_rules(cfn_model, rules_registry)
    if Logging.logger['log'].debug?
      Logging.logger['log'].debug "cfn_model: #{cfn_model}"
    end

    violations = []

    validate_cfn_nag_metadata(cfn_model)

    filter_rule_classes cfn_model, violations, rules_registry

    violations
  end

  private

  def inject_rule_arguments_into_rule(rule)
    self.class.rule_arguments.each do |rule_argument_name, rule_argument_value|
      if rule.respond_to?("#{rule_argument_name}=".to_sym)
        rule.send "#{rule_argument_name}=".to_sym, rule_argument_value
      end
    end
  end

  # rubocop:disable Style/RedundantBegin
  def filter_rule_classes(cfn_model, violations, rules_registry)
    rules_registry.rule_classes.each do |rule_class|
      begin
        filtered_cfn_model = cfn_model_with_suppressed_resources_removed(
          cfn_model: cfn_model,
          rule_id: rule_class.new.rule_id,
          allow_suppression: @allow_suppression,
          print_suppression: @print_suppression
        )
        rule = rule_class.new
        inject_rule_arguments_into_rule(rule)
        audit_result = rule.audit(filtered_cfn_model)
        violations << audit_result unless audit_result.nil?
      rescue ScriptError, StandardError => rule_error
        raise rule_error unless @isolate_custom_rule_exceptions

        $stderr.puts rule_error
      end
    end
  end
  # rubocop:enable Style/RedundantBegin
end
