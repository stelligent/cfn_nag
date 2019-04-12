# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class IamRoleNotPrincipalOnTrustPolicyRule < BaseRule
  def rule_text
    'IAM role should not allow Allow+NotPrincipal in its trust policy'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F6'
  end

  def audit_impl(cfn_model)
    violating_roles = cfn_model.resources_by_type('AWS::IAM::Role').select do |role|
      !role.assume_role_policy_document.allows_not_principal.empty?
    end

    violating_roles.map(&:logical_resource_id)
  end
end
