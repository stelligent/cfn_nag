# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/enforce_reference_parameter'
require 'cfn-nag/util/enforce_string_or_dynamic_reference'
require_relative 'base'

class SubPropertyWithListPasswordBaseRule < BaseRule
  def resource_type
    raise 'must implement in subclass'
  end

  def password_property
    raise 'must implement in subclass'
  end

  def sub_property_name; end

  def audit_impl(cfn_model)
    resources = cfn_model.resources_by_type(resource_type)

    violating_resources = resources.select do |resource|
      verify_insecure_string_and_parameter_with_list(
        cfn_model, resource, password_property, sub_property_name
      )
    end

    violating_resources.map(&:logical_resource_id)
  end
end

private

def verify_insecure_string_and_parameter_with_list(
  cfn_model, resource, password_property, sub_property_name
)
  sub_property_checks_result = ''

  resource.send(password_property).select do |sub_property|
    sub_property_checks_result = insecure_parameter?(
      cfn_model, sub_property[sub_property_name]
    ) || insecure_string_or_dynamic_reference?(
      cfn_model, sub_property[sub_property_name]
    )
  end

  sub_property_checks_result
end
