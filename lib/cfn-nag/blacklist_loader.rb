# frozen_string_literal: true

require 'yaml'

class BlackListLoader
  def initialize(rules_registry)
    @rules_registry = rules_registry
  end

  def load(blacklist_definition:)
    raise 'Empty profile' if blacklist_definition.strip == ''

    blacklist_ruleset = RuleIdSet.new

    blacklist_hash = load_blacklist_yaml(blacklist_definition)
    raise 'Blacklist is malformed' unless blacklist_hash.is_a? Hash

    rules_to_suppress = blacklist_hash.fetch('RulesToSuppress', {})
    raise 'Missing RulesToSuppress key in black list' if rules_to_suppress.empty?

    rule_ids_to_suppress = rules_to_suppress.map { |rule| rule['id'] }
    rule_ids_to_suppress.each do |rule_id|
      check_valid_rule_id rule_id
      blacklist_ruleset.add_rule rule_id
    end

    blacklist_ruleset
  end

  private

  def load_blacklist_yaml(blacklist_definition)
    YAML.safe_load(blacklist_definition)
  rescue StandardError => yaml_parse_error
    raise "YAML parse of blacklist failed: #{yaml_parse_error}"
  end

  def check_valid_rule_id(rule_id)
    return true unless @rules_registry.by_id(rule_id).nil?

    raise "#{rule_id} is not a legal rule identifier from: #{@rules_registry.ids}"
  end
end
