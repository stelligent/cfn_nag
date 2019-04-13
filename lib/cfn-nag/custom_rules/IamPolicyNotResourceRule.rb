# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class IamPolicyNotResourceRule < BaseRule
  def rule_text
    'IAM policy should not allow Allow+NotResource'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W22'
  end

  def audit_impl(cfn_model)
    violating_policies = cfn_model.resources_by_type('AWS::IAM::Policy')
                                  .select do |policy|
      !policy.policy_document.allows_not_resource.empty?
    end

    violating_policies.map(&:logical_resource_id)
  end
end
