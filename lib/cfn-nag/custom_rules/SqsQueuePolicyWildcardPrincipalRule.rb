require 'cfn-nag/violation'
require_relative 'base'

class SqsQueuePolicyWildcardPrincipalRule < BaseRule
  def rule_text
    'SQS Queue policy should not allow * principal'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F21'
  end

  def audit_impl(cfn_model)
    logical_resource_ids = []

    cfn_model.resources_by_type('AWS::SQS::QueuePolicy').each do |topic_policy|
      unless topic_policy.policy_document.wildcard_allowed_principals.empty?
        logical_resource_ids << topic_policy.logical_resource_id
      end
    end

    logical_resource_ids
  end
end
