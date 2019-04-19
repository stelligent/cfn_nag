# frozen_string_literal: true

require 'set'

# Container class for profiles
class RuleIdSet
  attr_reader :rule_ids

  def initialize
    @rule_ids = Set.new
  end

  # Add a Rule to a profile
  def add_rule(rule_id)
    @rule_ids << rule_id
  end

  # Does the list of rule ids contain rule_id?
  def contains_rule?(rule_id)
    @rule_ids.include? rule_id
  end
end
