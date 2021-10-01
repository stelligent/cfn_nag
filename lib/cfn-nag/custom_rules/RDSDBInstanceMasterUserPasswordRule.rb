# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'password_base_rule'

class RDSDBInstanceMasterUserPasswordRule < PasswordBaseRule
  def rule_text
    'RDS instance master user password must not be a plaintext string ' \
      'or a Ref to a Parameter with a Default value.  ' \
      'Can be Ref to a NoEcho Parameter without a Default, or a dynamic reference to a secretsmanager/ssm-secure value.'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F23'
  end

  def resource_type
    'AWS::RDS::DBInstance'
  end

  def password_property
    :masterUserPassword
  end
end
