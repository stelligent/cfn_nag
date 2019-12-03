# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'password_base_rule_sub_property_with_list'

class AmazonMQBrokerUsersPasswordRule < PasswordBaseRuleSubPropertyWithList
  def rule_text
    'AmazonMQ Broker Users Password must not be a plaintext ' \
    'string or a Ref to a NoEcho Parameter with a Default value.' \
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

  def password_property
    :users
  end

  def sub_property_name
    'Password'
  end
end
