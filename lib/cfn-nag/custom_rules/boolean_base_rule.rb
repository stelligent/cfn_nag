# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'
require 'cfn-nag/util/truthy'

##
# Derive from this rule to ensure that a resource
# always has a given property declared, and if it does, it's not set to false
# this does double duty for existence and being boolean/not false... strictly speaking
# it could be broken out but it does work this way
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
      boolean_property_value = resource.send(boolean_property)
      not_truthy?(boolean_property_value) || boolean_property_value == { 'Ref' => 'AWS::NoValue' }
    end

    violating_resources.map(&:logical_resource_id)
  end
end
