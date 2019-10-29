# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/enforce_reference_parameter'
require 'cfn-nag/util/enforce_string_or_dynamic_reference'
require_relative 'base'

class AmazonMQBrokerUserPasswordRule < BaseRule

  def rule_text
    'Amazon MQ Broker User should not show password in plain text, resolve an unsecure ssm string, or have a default value for parameter.'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F52'
  end

  def resource_type
    'AWS::AmazonMQ::Broker'
  end

  def audit_impl(cfn_model)
    resources = cfn_model.resources_by_type('AWS::AmazonMQ::Broker')

    violating_resources = resources.select do |resource|
      violating_users = resource.users.select do |user|
        insecure_parameter?(cfn_model, user['Password']) || \
        insecure_string_or_dynamic_reference?(cfn_model, user['Password']) || \
        user['Password'].nil?
      end
      !violating_users.empty?
    end

    violating_resources.map(&:logical_resource_id)
  end
end
