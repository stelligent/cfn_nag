require 'cfn-nag/violation'
require_relative 'base'

class IamRoleNotActionOnPermissionsPolicyRule < BaseRule
  def rule_text
    'IAM role should not allow Allow+NotAction'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W15'
  end

  def audit_impl(cfn_model)
    violating_roles = cfn_model.resources_by_type('AWS::IAM::Role').reject do |role|
      violating_policies = role.policy_objects.reject do |policy|
        policy.policy_document.allows_not_action.empty?
      end
      violating_policies.empty?
    end

    violating_roles.map(&:logical_resource_id)
  end
end
