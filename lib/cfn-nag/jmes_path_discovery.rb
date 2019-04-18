# frozen_string_literal: true

class JmesPathDiscovery
  def initialize(rule_registry)
    @rule_registry = rule_registry
  end

  def warning(id:, message:)
    @rule_registry.definition(id: id,
                              type: Violation::WARNING,
                              message: message)
  end

  def failure(id:, message:)
    @rule_registry.definition(id: id,
                              type: Violation::FAILING_VIOLATION,
                              message: message)
  end
end
