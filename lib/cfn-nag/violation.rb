# frozen_string_literal: true

require_relative 'rule_definition'

# Rule definition for violations
class Violation < RuleDefinition
  attr_reader :logical_resource_ids, :line_numbers

  def initialize(id:,
                 type:,
                 message:,
                 logical_resource_ids: [],
                 line_numbers: [])
    super id: id,
          type: type,
          message: message

    @logical_resource_ids = logical_resource_ids
    @line_numbers = line_numbers
  end

  def to_s
    "#{super} #{@logical_resource_ids}"
  end

  def to_h
    super.to_h.merge(
      logical_resource_ids: @logical_resource_ids,
      line_numbers: @line_numbers
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

    private

    def empty?(array)
      array.nil? || array.empty?
    end
  end
end
