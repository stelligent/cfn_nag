require 'cfn-nag/violation'
require_relative 'base'

class SnsTopicPolicyNotActionRule < BaseRule

  def rule_text
    'SNS Topic policy should not allow Allow+NotAction'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W19'
  end

  def audit_impl(cfn_model)
    violating_policies = cfn_model.resources_by_type('AWS::SNS::TopicPolicy').select do |policy|
      !policy.policyDocument.allows_not_action.empty?
    end

    violating_policies.map { |policy| policy.logical_resource_id }
  end
end