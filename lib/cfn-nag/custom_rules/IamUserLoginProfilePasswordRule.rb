# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/enforce_reference_parameter'
require 'cfn-nag/util/enforce_string_or_dynamic_reference'
require_relative 'base'

class IamUserLoginProfilePasswordRule < BaseRule
  def rule_text
    'If the IAM user LoginProile property exists, then its Password value should not ' +
    'show password in plain text, resolve an unsecure ssm string, or have a default value for parameter.'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F51'
  end

  def audit_impl(cfn_model)
    resources = cfn_model.resources_by_type('AWS::IAM::User')
    violating_resources = resources.select do |iam_user|
      violating_users?(cfn_model, iam_user)
    end
    violating_resources.map(&:logical_resource_id)
  end

  private
  
  def iam_user_has_insecure_password?(cfn_model, login_profile)
    if login_profile.has_key? 'Password'
      if insecure_parameter?(cfn_model, login_profile['Password'])
        true
      elsif insecure_string_or_dynamic_reference?(cfn_model, login_profile['Password'])
        true
      elsif login_profile['Password'].nil?
        true
      end
    else
      true    
    end
  end

  def violating_users?(cfn_model, iam_user)
    if !iam_user.loginProfile.nil?
      iam_user_has_insecure_password?(cfn_model, iam_user.loginProfile)
    else
      false
    end
  end 
end
