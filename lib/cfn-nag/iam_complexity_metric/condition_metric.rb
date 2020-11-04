# frozen_string_literal: true

require_relative 'weights'
require 'set'

class ConditionMetric
  include Weights

  def metric(statement)
    return 0 if statement.condition.nil?

    aggregate = 0
    aggregate += statement.condition.size * weights[:Condition]
    aggregate += confusing_value_operators(statement.condition)
    aggregate += if_exists_operators(statement.condition)
    aggregate += weights[:Null] if null_operator?(statement.condition)
    aggregate += values_with_policy_tags(statement.condition)
    aggregate
  end

  private

  def values_with_policy_tags(conditions)
    all_values(conditions).reduce(0) do |aggregate, value|
      aggregate + (contains_policy_tag?(value) ? weights[:PolicyVariables] : 0)
    end
  end

  def contains_policy_tag?(value)
    strip_special_characters(value).match(/.*\$\{.+\}.*/)
  end

  def strip_special_characters(value)
    special_characters.each do |special_character|
      value = value.gsub("${#{special_character}}", '')
    end
    value
  end

  def all_values(conditions)
    result = []
    conditions.each do |_, expression|
      expression.each do |_, value|
        case value
        when String
          result << value
        when Array
          result += value
        end
      end
    end
    result
  end

  def special_characters
    %w[$ * ?]
  end

  def null_operator?(conditions)
    conditions.find { |operator, _| operator == 'Null' }
  end

  def if_exists_operators(conditions)
    conditions.reduce(0) do |aggregate, condition|
      operator = condition[0]
      aggregate + (if_exists_operator?(operator) ? weights[:IfExists] : 0)
    end
  end

  def if_exists_operator?(operator)
    operator.end_with? 'IfExists'
  end

  def confusing_value_operators(conditions)
    conditions.reduce(0) do |aggregate, condition|
      operator = condition[0]
      aggregate + (confusing_value_operator?(operator) ? weights[:Condition] : 0)
    end
  end

  def confusing_value_operator?(operator)
    %w[ForAllValues ForAnyValues].find { |prefix| operator.start_with? prefix }
  end
end
