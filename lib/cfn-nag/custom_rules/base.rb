# frozen_string_literal: true

require 'cfn-nag/violation'

# Base class all Rules should subclass
class BaseRule
  ##
  # Returns a collection of logical resource ids
  #
  def audit_impl(_cfn_model)
    raise 'must implement in subclass'
  end

  ##
  # Returns nil when there are no violations
  # Returns a Violation object otherwise
  #
  def audit(cfn_model)
    logical_resource_ids = audit_impl(cfn_model)
    return if logical_resource_ids.empty?

    Violation.new(id: rule_id,
                  type: rule_type,
                  message: rule_text,
                  logical_resource_ids: logical_resource_ids)
  end
end
