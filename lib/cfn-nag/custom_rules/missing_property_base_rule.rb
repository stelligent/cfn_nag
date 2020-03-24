# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/enforce_reference_parameter'
require 'cfn-nag/util/enforce_string_or_dynamic_reference'
require_relative 'base'

class MissingPropertyBaseRule < BaseRule
  def resource_type
    raise 'must implement in subclass'
  end

  def property_name
    raise 'must implement in subclass'
  end

  def audit_impl(cfn_model)
    resources = cfn_model.resources_by_type(resource_type)

    violating_resources = resources.select do |resource|
      resource.send(property_name).nil?
    end

    violating_resources.map(&:logical_resource_id)
  end
end
