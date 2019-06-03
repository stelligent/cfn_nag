# frozen_string_literal: true

require_relative 'rule_definition'

class RuleRegistry
  attr_reader :rules, :duplicate_ids

  def initialize
    @rules = []
    @duplicate_ids = []
  end

  def duplicate_ids?
    @duplicate_ids.count.positive?
  end

  def definition(id:,
                 type:,
                 message:)
    rule_definition = RuleDefinition.new(id: id,
                                         type: type,
                                         message: message)
    existing_def = by_id id

    if existing_def.nil?
      add_rule rule_definition
    else
      @duplicate_ids << {
        id: id,
        new_message: message,
        registered_message: existing_def.message
      }
    end
  end

  def by_id(id)
    @rules.find { |rule| rule.id == id }
  end

  def warnings
    @rules.select { |rule| rule.type == RuleDefinition::WARNING }
  end

  def failings
    @rules.select { |rule| rule.type == RuleDefinition::FAILING_VIOLATION }
  end

  private

  def add_rule(violation_def)
    @rules << violation_def
    violation_def
  end
end
