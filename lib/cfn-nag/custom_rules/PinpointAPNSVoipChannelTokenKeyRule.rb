# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'password_base_rule'

class PinpointAPNSVoipChannelTokenKeyRule < PasswordBaseRule
  def rule_text
    'Pinpoint APNSChannel TokenKey must not be a plaintext string ' \
    'or a Ref to a Parameter with a Default value.  ' \
    'Can be Ref to a NoEcho Parameter without a Default, or a dynamic reference to a secretsmanager value.'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F49'
  end

  def resource_type
    'AWS::Pinpoint::APNSVoipChannel'
  end

  def password_property
    :tokenKey
  end
end
