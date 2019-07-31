# frozen_string_literal: true

require_relative 'custom_rule_loader'
require_relative 'profile_loader'
require_relative 'result_view/rules_view'

class CfnNagRuleDumper
  def initialize(profile_definition: nil,
                 rule_directory: nil,
                 output_format: nil)
    @rule_directory = rule_directory
    @profile_definition = profile_definition
    @output_format = output_format
  end

  def dump_rules
    custom_rule_loader = CustomRuleLoader.new(rule_directory: @rule_directory)
    rule_registry = custom_rule_loader.rule_definitions

    profile = nil
    unless @profile_definition.nil?
      profile = ProfileLoader.new(rule_registry)
                             .load(profile_definition: @profile_definition)
    end

    RulesView.new.emit(rule_registry, profile, output_format: @output_format)
  end
end
