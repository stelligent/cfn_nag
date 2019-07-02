# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'password_base_rule'

class PinpointAPNSSandboxChannelTokenKeyRule < PasswordBaseRule
  def rule_text
    'Pinpoint APNSSandboxChannel TokenKey must not be a plaintext string ' \
    'or a Ref to a NoEcho Parameter with a Default value.'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F43'
  end

  def resource_type
    'AWS::Pinpoint::APNSSandboxChannel'
  end

  def password_property
    :tokenKey
  end
end
