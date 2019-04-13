# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class SqsQueuePolicyWildcardActionRule < BaseRule
  def rule_text
    'SQS Queue policy should not allow * action'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F20'
  end

  def audit_impl(cfn_model)
    logical_resource_ids = []

    cfn_model.resources_by_type('AWS::SQS::QueuePolicy').each do |queue_policy|
      unless queue_policy.policy_document.wildcard_allowed_actions.empty?
        logical_resource_ids << queue_policy.logical_resource_id
      end
    end

    logical_resource_ids
  end
end
