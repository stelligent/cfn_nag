# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'password_base_rule_sub_property_with_list'

class OpsWorksStackRdsDbInstancesDbPasswordRule < PasswordBaseRuleSubPropertyWithList
  def rule_text
    'OpsWorks Stack RDS DbInstance DbPassword must not be a plaintext ' \
    'string or a Ref to a NoEcho Parameter with a Default value.' \
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F59'
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
