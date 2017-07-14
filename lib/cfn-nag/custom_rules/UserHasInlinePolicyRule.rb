require 'cfn-nag/violation'
require_relative 'base'

class UserHasInlinePolicyRule < BaseRule

  def rule_text
    'IAM user should not have any inline policies.  Should be centralized Policy object on group'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F10'
  end

  def audit_impl(cfn_model)
    violating_users = cfn_model.iam_users.select do |iam_user|
      iam_user.policies.size > 0
    end

    violating_users.map { |violating_user| violating_user.logical_resource_id }
  end
end
