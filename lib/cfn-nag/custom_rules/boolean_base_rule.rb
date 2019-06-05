# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'
require 'cfn-nag/util/truthy.rb'

class BooleanBaseRule < BaseRule
  def resource_type
    raise 'must implement in subclass'
  end

  def boolean_property
    raise 'must implement in subclass'
  end

  def audit_impl(cfn_model)
    resources = cfn_model.resources_by_type(resource_type)

    violating_resources = resources.select do |resource|
      not_truthy?(resource.send(boolean_property))
    end

    violating_resources.map(&:logical_resource_id)
  end
end
