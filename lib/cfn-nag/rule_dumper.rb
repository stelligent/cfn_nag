# frozen_string_literal: true

require_relative 'custom_rule_loader'
require_relative 'profile_loader'
require_relative 'result_view/rules_view'
require_relative 'rule_repository_loader'

class CfnNagRuleDumper
  def initialize(profile_definition: nil,
                 rule_directory: nil,
                 output_format: nil,
                 rule_repository_definitions: [])
    @rule_directory = rule_directory
    @profile_definition = profile_definition
    @output_format = output_format
    @rule_repository_definitions = rule_repository_definitions
  end

  def dump_rules
    rule_registry = FileBasedRuleRepo.new(@rule_directory).discover_rules
    rule_registry.merge! GemBasedRuleRepo.new.discover_rules
    rule_registry = RuleRepositoryLoader.new.merge(rule_registry, @rule_repository_definitions)

    profile = nil
    unless @profile_definition.nil?
      profile = ProfileLoader.new(rule_registry)
                             .load(profile_definition: @profile_definition)
    end

    RulesView.new.emit(rule_registry, profile, output_format: @output_format)
  end
end
