# frozen_string_literal: true

require 'yaml'

class DenyListLoader
  def initialize(rules_registry)
    @rules_registry = rules_registry
  end

  def load(deny_list_definition:)
    raise 'Empty profile' if deny_list_definition.strip == ''

    deny_list_ruleset = RuleIdSet.new

    deny_list_hash = load_deny_list_yaml(deny_list_definition)
    raise 'Deny list is malformed' unless deny_list_hash.is_a? Hash

    rules_to_suppress = deny_list_hash.fetch('RulesToSuppress', {})
    raise 'Missing RulesToSuppress key in deny list' if rules_to_suppress.empty?

    rule_ids_to_suppress = rules_to_suppress.map { |rule| rule['id'] }
    rule_ids_to_suppress.each do |rule_id|
      check_valid_rule_id rule_id
      deny_list_ruleset.add_rule rule_id
    end

    deny_list_ruleset
  end

  private

  def load_deny_list_yaml(deny_list_definition)
    YAML.safe_load(deny_list_definition)
  rescue StandardError => yaml_parse_error
    raise "YAML parse of deny list failed: #{yaml_parse_error}"
  end

  def check_valid_rule_id(rule_id)
    return true unless @rules_registry.by_id(rule_id).nil?

    raise "#{rule_id} is not a legal rule identifier from: #{@rules_registry.ids}"
  end
end
