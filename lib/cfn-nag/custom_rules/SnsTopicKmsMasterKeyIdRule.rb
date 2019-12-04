# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class SnsTopicKmsMasterKeyIdRule < BaseRule
  def rule_text
    'SNS Topic policy should specify KmsMasterKeyId property'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W47'
  end

  def audit_impl(cfn_model)
    violating_sns_topics = cfn_model.resources_by_type('AWS::SNS::Topic').select do |topic|
      topic.kmsMasterKeyId.nil?
    end

    violating_sns_topics.map(&:logical_resource_id)
  end
end
