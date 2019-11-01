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

  def check_password_property(cfn_model, login_profile)
    # Checks to make sure 'LoginProfile' property has the key 'Password' defined.
    # Also check if the value for the 'Password' key is nil
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

  def check_login_profile_property(login_profile)
    # Checks to see if the 'LoginProfile' property that is part of the 'AWS::IAM::User'
    # resource exists and is defined.
    !login_profile.nil?
  end

  def get_violating_iam_users(cfn_model, resource)
    # If the 'LoginProfile' property is defined then grab the violating IamUser resources
    # with 'Password' key defined.
    if check_login_profile_property(resource.loginProfile)
      check_password_property(cfn_model, resource.loginProfile)
    else
      false
    end
  end 

  def audit_impl(cfn_model)
    resources = cfn_model.resources_by_type('AWS::IAM::User')
    violating_resources = resources.select do |resource|
      get_violating_iam_users(cfn_model, resource)
    end
    violating_resources.map(&:logical_resource_id)
  end
end
