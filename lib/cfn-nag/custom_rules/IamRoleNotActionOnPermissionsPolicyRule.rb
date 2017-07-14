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
    violating_roles = cfn_model.resources_by_type('AWS::IAM::Role').select do |role|
      violating_policies = role.policies.select do |policy|
        !policy.policyDocument.allows_not_action.empty?
      end
      !violating_policies.empty?
    end

    violating_roles.map { |role| role.logical_resource_id }
  end
end
