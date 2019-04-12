# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class IamManagedPolicyWildcardActionRule < BaseRule
  def rule_text
    'IAM managed policy should not allow * action'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F5'
  end

  def audit_impl(cfn_model)
    violating_policies = cfn_model.resources_by_type('AWS::IAM::ManagedPolicy')
                                  .select do |policy|
      !policy.policy_document.wildcard_allowed_actions.empty?
    end

    violating_policies.map(&:logical_resource_id)
  end
end
