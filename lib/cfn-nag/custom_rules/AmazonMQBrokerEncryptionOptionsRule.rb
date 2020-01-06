# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class AmazonMQBrokerEncryptionOptionsRule < BaseRule
  def rule_text
    'AmazonMQ Broker should specify EncryptionOptions'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W53'
  end

  def audit_impl(cfn_model)
    violating_brokers = cfn_model.resources_by_type('AWS::AmazonMQ::Broker').select do |broker|
      broker.encryptionOptions.nil?
    end

    violating_brokers.map(&:logical_resource_id)
  end
end
