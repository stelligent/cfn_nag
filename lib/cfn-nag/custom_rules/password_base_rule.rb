# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/enforce_reference_parameter'
require 'cfn-nag/util/enforce_string_or_dynamic_reference'
require_relative 'base'

class PasswordBaseRule < BaseRule
  def resource_type
    raise 'must implement in subclass'
  end

  def password_property
    raise 'must implement in subclass'
  end

  def audit_impl(cfn_model)
    resources = cfn_model.resources_by_type(resource_type)

    violating_resources = resources.select do |resource|
      if resource.send(password_property).nil?
        false
      else
        insecure_parameter?(cfn_model, resource.send(password_property)) ||
          insecure_string_or_dynamic_reference?(cfn_model,
                                                resource.send(password_property))
      end
    end

    violating_resources.map(&:logical_resource_id)
  end
end
