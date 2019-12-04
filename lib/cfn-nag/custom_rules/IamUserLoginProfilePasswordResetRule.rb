# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/truthy'
require_relative 'base'

class IamUserLoginProfilePasswordResetRule < BaseRule
  def rule_text
    'IAM User Login Profile should exist and have PasswordResetRequired property set to true'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W50'
  end

  def audit_impl(cfn_model)
    violating_iam_users = cfn_model.resources_by_type('AWS::IAM::User').select do |iam_user|
      violating_iam_users?(iam_user)
    end

    violating_iam_users.map(&:logical_resource_id)
  end

  private

  def iam_user_password_reset_required_key?(login_profile)
    if login_profile.key? 'PasswordResetRequired'
      if login_profile['PasswordResetRequired'].nil?
        true
      elsif not_truthy?(login_profile['PasswordResetRequired'])
        true
      end
    else
      true
    end
  end

  def violating_iam_users?(iam_user)
    if !iam_user.loginProfile.nil?
      iam_user_password_reset_required_key?(iam_user.loginProfile)
    else
      false
    end
  end
end
