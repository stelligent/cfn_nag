# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'password_base_rule'

class OpsWorksStackCustomCookbooksSourcePasswordRule < PasswordBaseRule
  def rule_text
    'OpsWorks Stack CustomCookbooksSource Password must not be a plaintext ' \
    'string or a Ref to a Parameter with a Default value.  ' \
    'Can be Ref to a NoEcho Parameter without a Default, or a dynamic reference to a secretsmanager/ssm-secure value.'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F62'
  end

  def resource_type
    'AWS::OpsWorks::Stack'
  end

  def password_property
    :customCookbooksSource
  end

  def sub_property_name
    'Password'
  end
end
