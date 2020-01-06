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
      resource_with_insecure_subproperty_within_list_property?(
        cfn_model, resource, password_property, sub_property_name
      )
    end

    violating_resources.map(&:logical_resource_id)
  end

  private

  ##
  # This method name is a mouthful.  Consider a cfn resource with a property that is a list
  # like OpsworkStack::RdsDbInstances.  The elements of that list include a password property.
  # This predicate goes looking for unsafe password values "down" in the elements of the list
  #
  def resource_with_insecure_subproperty_within_list_property?(
    cfn_model, resource, password_property, sub_property_name
  )
    property_list = resource.send(password_property)
    return false unless property_list

    property_list.find do |property_element|
      sub_value = property_element[sub_property_name]
      insecure_parameter?(cfn_model, sub_value) || insecure_string_or_dynamic_reference?(cfn_model, sub_value)
    end
  end
end
