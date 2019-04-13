# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class PolicyOnUserRule < BaseRule
  def rule_text
    'IAM policy should not apply directly to users.  Should be on group'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F11'
  end

  def audit_impl(cfn_model)
    violating_policies = cfn_model.resources_by_type('AWS::IAM::Policy').reject do |policy|
      policy.users.empty?
    end

    violating_policies.map(&:logical_resource_id)
  end
end
