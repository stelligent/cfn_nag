# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'password_base_rule'

class DMSEndpointPasswordRule < PasswordBaseRule
  def rule_text
    'DMS Endpoint password must not be a plaintext string ' \
    'or a Ref to a NoEcho Parameter with a Default value.'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F37'
  end

  def resource_type
    'AWS::DMS::Endpoint'
  end

  def property_name
    :password
  end
end
