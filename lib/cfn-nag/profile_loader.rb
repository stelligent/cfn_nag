# frozen_string_literal: true

require_relative 'rule_id_set'

class ProfileLoader
  def initialize(rules_registry)
    @rules_registry = rules_registry
  end

  # Load rules from a profile definition
  def load(profile_definition:)
    # coerce falsy profile_definition into empty string for
    # empty profile check
    profile_definition ||= ''
    raise 'Empty profile' if profile_definition.strip == ''

    new_profile = RuleIdSet.new

    profile_definition.each_line do |line|
      next unless (rule_id = rule_line_match(line))

      check_valid_rule_id rule_id
      new_profile.add_rule rule_id
    end
    new_profile
  end

  private

  # Parses a line, returns first matching line or false if
  # no match
  def rule_line_match(rule_id)
    rule_id = rule_id.chomp
    matches = /^([a-zA-Z]*?[0-9]+)\s*(.*)/.match(rule_id)
    return false if matches.nil?

    matches.captures.first
  end

  # Return ids of rules in registry
  def rules_ids
    @rules_registry.rules.map(&:id)
  end

  # Return true if rule_id is valid (present in rules registry),
  # else raise an error
  def check_valid_rule_id(rule_id)
    return true unless @rules_registry.by_id(rule_id).nil?

    raise "#{rule_id} is not a legal rule identifier from: #{rules_ids}"
  end
end
