# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/truthy'
require 'cfn-nag/util/parameter_reference_and_default_value'
require_relative 'base'

class CognitoIdentityPoolAllowUnauthenticatedIdentitiesRule < BaseRule
  def rule_text
    'AWS::Cognito::IdentityPool AllowUnauthenticatedIdentities property should be false ' \
    'but CAN be true if proper restrictive IAM roles and permissions are established for unauthenticated users.'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W86'
  end

  def audit_impl(cfn_model)
    violating_identity_pools = cfn_model.resources_by_type('AWS::Cognito::IdentityPool').select do |identity_pool|
      violating_identity_pool?(identity_pool)
    end

    violating_identity_pools.map(&:logical_resource_id)
  end

  private

  def violations?(property_value)
    truthy?(property_value)
  end

  def violating_identity_pool?(identity_pool)
    ip_prop = identity_pool.allowUnauthenticatedIdentities
    if property_a_param_ref?(identity_pool, ip_prop)
      prop_default_value = get_default_param_value(identity_pool, ip_prop)
      if prop_default_value.nil?
      else
        violations?(prop_default_value)
      end
    else
      violations?(ip_prop)
    end
  end
end
