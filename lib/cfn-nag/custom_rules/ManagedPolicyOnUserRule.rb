# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class ManagedPolicyOnUserRule < BaseRule
  def rule_text
    'IAM managed policy should not apply directly to users.  Should be on group'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F12'
  end

  def audit_impl(cfn_model)
    violating_policies = cfn_model.resources_by_type('AWS::IAM::ManagedPolicy').reject do |policy|
      policy.users.empty?
    end

    violating_policies.map(&:logical_resource_id)
  end
end
