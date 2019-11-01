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

  def check_password_property(cfn_model, user)
    # Checks to make sure 'Users' property has the key 'Password' defined.
    # Also check if the value for the 'Password' key is nil
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

  def check_user_property(user_property)
    # Checks to make sure that the 'Users' property that is part of the 'AWS::AmazonMQ::Broker'
    # resource exists and is defined.
    if !user_property.nil?
      true
    end
  end

  def get_violating_users(cfn_model, resource)
    # If the 'Users' property is defined then try to grab the violating user password keys
    # that are oare of the 'Users' property list.
    if check_user_property(resource.users)
      violating_users = resource.users.select do |user|
        check_password_property(cfn_model, user)
      end
      !violating_users.empty?
    else
      true
    end
  end 

  def audit_impl(cfn_model)
    resources = cfn_model.resources_by_type('AWS::AmazonMQ::Broker')
    violating_resources = resources.select do |resource|
      get_violating_users(cfn_model, resource)
    end
    violating_resources.map(&:logical_resource_id)
  end
end
