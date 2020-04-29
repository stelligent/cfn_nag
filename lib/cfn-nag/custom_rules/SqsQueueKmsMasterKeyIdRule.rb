# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'boolean_base_rule'

class SqsQueueKmsMasterKeyIdRule < BooleanBaseRule
  def rule_text
    'SQS Queue should specify KmsMasterKeyId property'
  end

  def resource_type
    'AWS::SQS::Queue'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W48'
  end

  def boolean_property
    :kmsMasterKeyId
  end
end
