# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class SqsQueueKmsMasterKeyIdRule < BaseRule
  def rule_text
    'SQS Queue should specify KmsMasterKeyId property'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W48'
  end

  def audit_impl(cfn_model)
    violating_sqs_queues = cfn_model.resources_by_type('AWS::SQS::Queue').select do |sqs_queue|
      sqs_queue.kmsMasterKeyId.nil?
    end

    violating_sqs_queues.map(&:logical_resource_id)
  end
end
