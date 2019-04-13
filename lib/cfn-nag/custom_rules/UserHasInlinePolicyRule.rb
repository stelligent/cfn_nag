# frozen_string_literal: true

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
    violating_users = cfn_model.iam_users.reject do |iam_user|
      iam_user.policy_objects.empty?
    end

    violating_users.map(&:logical_resource_id)
  end
end
