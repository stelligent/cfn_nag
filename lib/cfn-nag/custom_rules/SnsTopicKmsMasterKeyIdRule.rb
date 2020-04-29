# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'boolean_base_rule'

class SnsTopicKmsMasterKeyIdRule < BooleanBaseRule
  def rule_text
    'SNS Topic should specify KmsMasterKeyId property'
  end

  def resource_type
    'AWS::SNS::Topic'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W47'
  end

  def boolean_property
    :kmsMasterKeyId
  end
end
