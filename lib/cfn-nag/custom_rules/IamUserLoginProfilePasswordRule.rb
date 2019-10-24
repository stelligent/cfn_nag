# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'password_base_rule'

class IamUserLoginProfilePasswordRule < PasswordBaseRule
  def rule_text
    'IAM user login profile should not show password in plain text'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F51'
  end

  def resource_type
    'AWS::IAM::User'
  end

  def password_property
    :loginProfile
  end

  def sub_property_name
    'Password'
  end
end