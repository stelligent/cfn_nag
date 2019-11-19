# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/enforce_reference_parameter'
require 'cfn-nag/util/enforce_string_or_dynamic_reference'
require_relative 'base'

class AmazonMQBrokerUserPasswordRule < BaseRule

  def rule_text
    'Amazon MQ Broker resource Users property should exist and its Password property value ' +
    'should not show password in plain text, resolve an unsecure ssm string, or have a default value for parameter.'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F52'
  end

  def audit_impl(cfn_model)
    brokers = cfn_model.resources_by_type('AWS::AmazonMQ::Broker')
    violating_brokers = brokers.select do |mq_broker|
      violating_users?(cfn_model, mq_broker)
    end
    violating_brokers.map(&:logical_resource_id)
  end

  private

  def user_has_insecure_password?(cfn_model, user)
    if user.has_key? 'Password'
      if insecure_parameter?(cfn_model, user['Password'])
        true
      elsif insecure_string_or_dynamic_reference?(cfn_model, user['Password'])
        true
      elsif user['Password'].nil?
        true
      end
    else
      true    
    end
  end

  def violating_users?(cfn_model, mq_broker)
    if !mq_broker.users.nil?
      violating_users = mq_broker.users.select do |user|
        user_has_insecure_password?(cfn_model, user)
      end
      !violating_users.empty?
    else
      true
    end
  end 
end
