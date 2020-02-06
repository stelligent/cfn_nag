# frozen_string_literal: true

require 'cfn-model'
require 'logging'
require_relative 'rule_registry'
require_relative 'rule_repos/file_based_rule_repo'
require_relative 'rule_repos/gem_based_rule_repo'
require_relative 'rule_repos/s3_based_rule_repo'
require_relative 'rule_repository_loader'

##
# This object can discover the internal and custom user-provided rules and
# apply these rules to a CfnModel object
#
class CustomRuleLoader
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

  # rubocop:disable Style/RedundantBegin
  def filter_rule_classes(cfn_model, violations, rules_registry)
    rules_registry.rule_classes.each do |rule_class|
      begin
        filtered_cfn_model = cfn_model_with_suppressed_resources_removed(
          cfn_model: cfn_model,
          rule_id: rule_class.new.rule_id,
          allow_suppression: @allow_suppression
        )
        audit_result = rule_class.new.audit(filtered_cfn_model)
        violations << audit_result unless audit_result.nil?
      rescue ScriptError, StandardError => rule_error
        raise rule_error unless @isolate_custom_rule_exceptions

        STDERR.puts rule_error
      end
    end
  end
  # rubocop:enable Style/RedundantBegin

  def rules_to_suppress(resource)
    if resource.metadata &&
       resource.metadata['cfn_nag'] &&
       resource.metadata['cfn_nag']['rules_to_suppress']

      resource.metadata['cfn_nag']['rules_to_suppress']
    end
  end

  def collect_mangled_metadata(cfn_model)
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
    mangled_metadatas
  end

  # XXX given mangled_metadatas is never used or returned,
  # STDERR emit can be moved to unless block
  def validate_cfn_nag_metadata(cfn_model)
    mangled_metadatas = collect_mangled_metadata(cfn_model)
    mangled_metadatas.each do |mangled_metadata|
      logical_resource_id = mangled_metadata.first
      mangled_rules = mangled_metadata[1]

      STDERR.puts "#{logical_resource_id} has missing cfn_nag suppression " \
                  "rule id: #{mangled_rules}"
    end
  end

  def suppress_resource?(rules_to_suppress, rule_id, logical_resource_id)
    found_suppression_rule = rules_to_suppress.find do |rule_to_suppress|
      next if rule_to_suppress['id'].nil?

      rule_to_suppress['id'] == rule_id
    end
    if found_suppression_rule && @print_suppression
      message = "Suppressing #{rule_id} on #{logical_resource_id} for " \
                "reason: #{found_suppression_rule['reason']}"
      STDERR.puts message
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
end
