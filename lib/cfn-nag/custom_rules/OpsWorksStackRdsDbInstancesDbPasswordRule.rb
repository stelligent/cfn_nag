# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'sub_property_with_list_password_base_rule'

class OpsWorksStackRdsDbInstancesDbPasswordRule < SubPropertyWithListPasswordBaseRule
  def rule_text
    'OpsWorks Stack RDS DbInstance DbPassword must not be a plaintext string '\
    'or a Ref to a Parameter with a Default value.  ' \
    'Can be Ref to a NoEcho Parameter without a Default, or a dynamic reference to a secretsmanager/ssm-secure value.'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F54'
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
