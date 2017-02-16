require_relative 'violation'

class RuleRegistry

  attr_reader :rules

  def initialize
    @rules = []
  end

  def definition(id:,
                 type:,
                 message:)
    violation_def = Violation.new(id: id,
                                  type: type,
                                  message: message)
    existing_def = @rules.find { |definition| definition == violation_def }

    if existing_def.nil?
      add_rule violation_def
    else
      existing_def
    end
  end

  # FATAL applies to multiple rules
  def by_id(id)
    @rules.select { |rule| rule.id == id }
  end

  def warnings
    @rules.select { |rule| rule.type == Violation::WARNING }
  end

  def failings
    @rules.select { |rule| rule.type == Violation::FAILING_VIOLATION }
  end

  private

  def add_rule(violation_def)
    @rules << violation_def
    violation_def
  end
end