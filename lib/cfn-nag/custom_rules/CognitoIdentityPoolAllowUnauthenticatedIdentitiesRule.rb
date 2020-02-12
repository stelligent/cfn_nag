# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'
require 'cfn-nag/util/truthy'

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
      violating_identity_pool?(identity_pool.allowUnauthenticatedIdentities)
    end

    violating_identity_pools.map(&:logical_resource_id)
  end

  private

  def violating_identity_pool?(identity_pool)
    truthy?(identity_pool)
  end
end
