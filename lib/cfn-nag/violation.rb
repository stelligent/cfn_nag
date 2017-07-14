require_relative 'rule_definition'

class Violation < RuleDefinition
  attr_reader :logical_resource_ids

  def initialize(id:,
                 type:,
                 message:,
                 logical_resource_ids: nil)
    super id: id,
          type: type,
          message: message

    @logical_resource_ids = logical_resource_ids
  end

  def to_s
    "#{super.to_s} #{@logical_resource_ids}"
  end

  def to_h
    super.to_h.merge({
      logical_resource_ids: @logical_resource_ids
    })
  end

  def self.count_warnings(violations)
    violations.inject(0) do |count, violation|
      if violation.type == Violation::WARNING
        if empty?(violation.logical_resource_ids)
          count += 1
        else
          count += violation.logical_resource_ids.size
        end
      end
      count
    end
  end

  def self.count_failures(violations)
    violations.inject(0) do |count, violation|
      if violation.type == Violation::FAILING_VIOLATION
        if empty?(violation.logical_resource_ids)
          count += 1
        else
          count += violation.logical_resource_ids.size
        end
      end
      count
    end
  end

  private

  def self.empty?(array)
    array.nil? || array.size ==0
  end
end