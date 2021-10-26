# frozen_string_literal: true

require_relative 'rule_definition'

# Rule definition for violations
class Violation < RuleDefinition
  attr_reader :logical_resource_ids, :line_numbers, :element_types

  # rubocop:disable Metrics/ParameterLists
  def initialize(id:,
                 name:,
                 type:,
                 message:,
                 logical_resource_ids: [],
                 line_numbers: [],
                 element_types: [])
    super id: id,
          name: name,
          type: type,
          message: message

    @logical_resource_ids = logical_resource_ids
    @line_numbers = line_numbers
    @element_types = element_types
  end
  # rubocop:enable Metrics/ParameterLists

  def to_s
    "#{super} #{@logical_resource_ids}"
  end

  def to_h
    super.to_h.merge(
      logical_resource_ids: @logical_resource_ids,
      line_numbers: @line_numbers,
      element_types: @element_types
    )
  end

  class << self
    def count_warnings(violations)
      violations.inject(0) do |count, violation|
        if violation.type == Violation::WARNING
          count += if empty?(violation.logical_resource_ids)
                     1
                   else
                     violation.logical_resource_ids.size
                   end
        end
        count
      end
    end

    def count_failures(violations)
      violations.inject(0) do |count, violation|
        if violation.type == Violation::FAILING_VIOLATION
          count += if empty?(violation.logical_resource_ids)
                     1
                   else
                     violation.logical_resource_ids.size
                   end
        end
        count
      end
    end

    def fatal_violation(message)
      Violation.new(id: 'FATAL',
                    name: 'system',
                    type: Violation::FAILING_VIOLATION,
                    message: message)
    end

    private

    def empty?(array)
      array.nil? || array.empty?
    end
  end
end
