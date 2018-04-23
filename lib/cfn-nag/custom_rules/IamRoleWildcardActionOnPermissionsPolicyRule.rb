require 'cfn-nag/violation'
require_relative 'base'

class IamRoleWildcardActionOnPermissionsPolicyRule < BaseRule
  def rule_text
    'IAM role should not allow * action on its permissions policy'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F3'
  end

  def audit_impl(cfn_model)
    violating_roles = cfn_model.resources_by_type('AWS::IAM::Role').reject do |role|
      violating_policies = role.policy_objects.reject do |policy|
        policy.policy_document.wildcard_allowed_actions.empty?
      end
      violating_policies.empty?
    end

    violating_roles.map(&:logical_resource_id)
  end
end
