# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

# Check for a resource from being used
class ResourceBaseRule < BaseRule
  def resource_type
    raise 'must implement in subclass'
  end

  def audit_impl(cfn_model)
    violating_resources = cfn_model.resources_by_type(resource_type)
    violating_resources.map(&:logical_resource_id)
  end
end
