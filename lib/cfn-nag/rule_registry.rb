# frozen_string_literal: true

require 'set'
require_relative 'rule_definition'

##
# This registry contains all the discovered rule classes that are to be used
# for inspection.
#
# Historically this just kept the metadata around the rules that percolated into
# the violation reports.  This is no longer true as the rule discovery logic is being
# split out to support multiple discover algorithms (i.e. rule repositories).
# The CustomRuleLoader asks the discovery delegate to the rule classes, and that
# discovery returns this object with the rule definitions, and the class itself
# that can be invoked to do an inspection
#
class RuleRegistry
  attr_reader :rules, :duplicate_ids, :rule_classes

  def initialize
    @rules = []
    @duplicate_ids = []
    @rule_classes = Set.new
  end

  def duplicate_ids?
    @duplicate_ids.count.positive?
  end

  def merge!(other_rule_registry)
    @rules += other_rule_registry.rules
    @duplicate_ids += other_rule_registry.duplicate_ids
    @rule_classes += other_rule_registry.rule_classes
  end

  def definition(rule_class)
    @rule_classes.add rule_class

    rule = rule_class.new

    existing_def = by_id rule.rule_id

    if existing_def.nil?
      rule_definition = RuleDefinition.new(
        id: rule.rule_id,
        type: rule.rule_type,
        message: rule.rule_text
      )
      add_rule rule_definition
    else
      @duplicate_ids << {
        id: rule.rule_id,
        new_message: rule.rule_text,
        registered_message: existing_def.message
      }
    end
  end

  def by_id(id)
    @rules.find { |rule| rule.id == id }
  end

  def ids
    @rules.map(&:id)
  end

  def warnings
    @rules.select { |rule| rule.type == RuleDefinition::WARNING }
  end

  def failings
    @rules.select { |rule| rule.type == RuleDefinition::FAILING_VIOLATION }
  end

  private

  def add_rule(rule_definition)
    @rules << rule_definition
    rule_definition
  end
end
