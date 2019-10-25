# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'password_base_rule'

class OpsWorksStackRdsDbInstancePasswordRule < PasswordBaseRule
  def rule_text
    'OpsWorks Stack RDS DBInstance should not show password in plain text'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F52'
  end

  def resource_type
    'AWS::OpsWorks::Stack'
  end

  def password_property
    :rdsDbInstances
  end

  def sub_property_name
    'DbPassword'
  end
end
