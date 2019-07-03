# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'password_base_rule'

class PinpointAPNSVoipChannelPrivateKeyRule < PasswordBaseRule
  def rule_text
    'Pinpoint APNSVoipChannel PrivateKey must not be a plaintext string ' \
    'or a Ref to a NoEcho Parameter with a Default value.'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F48'
  end

  def resource_type
    'AWS::Pinpoint::APNSVoipChannel'
  end

  def password_property
    :privateKey
  end
end
