# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'password_base_rule'

class OpsWorksAppAppSourcePasswordRule < PasswordBaseRule
  def rule_text
    'OpsWorks App AppSource Password must not be a plaintext ' \
    'string or a Ref to a NoEcho Parameter with a Default value.' \
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F67'
  end

  def resource_type
    'AWS::OpsWorks::App'
  end

  def password_property
    :appSource
  end

  def sub_property_name
    'Password'
  end
end
