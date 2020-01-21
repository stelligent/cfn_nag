# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'password_base_rule'

class LambdaPermissionEventSourceTokenRule < PasswordBaseRule
  def rule_text
    'Lambda Permission EventSourceToken must not be a plaintext string ' \
    'or a Ref to a NoEcho Parameter with a Default value.'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F45'
  end

  def resource_type
    'AWS::Lambda::Permission'
  end

  def password_property
    :eventSourceToken
  end
end
