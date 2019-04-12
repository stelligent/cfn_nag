# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class IamRoleWildcardActionOnTrustPolicyRule < BaseRule
  def rule_text
    'IAM role should not allow * action on its trust policy'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F2'
  end

  def audit_impl(cfn_model)
    violating_roles = cfn_model.resources_by_type('AWS::IAM::Role').select do |role|
      !role.assume_role_policy_document.wildcard_allowed_actions.empty?
    end

    violating_roles.map(&:logical_resource_id)
  end
end
