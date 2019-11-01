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

  def check_for_login_profile(login_profile)
    !login_profile.nil?
  end

  def check_for_password_reset_required_key(login_profile)
    login_profile.has_key? 'PasswordResetRequired'
  end

  def get_violating_iam_users(iam_user)
    if check_for_login_profile(iam_user.loginProfile)
      if check_for_password_reset_required_key(iam_user.loginProfile)
        if iam_user.loginProfile['PasswordResetRequired'].nil?
          true
        elsif not_truthy?(iam_user.loginProfile['PasswordResetRequired'])
          true
        end
      else
        true
      end
    else
      false
    end
  end     

  def audit_impl(cfn_model)
    violating_iam_users = cfn_model.resources_by_type('AWS::IAM::User').select do |iam_user|
      get_violating_iam_users(iam_user)
    end

    violating_iam_users.map(&:logical_resource_id)
  end
  # def audit_impl(cfn_model)
  #   violating_iam_users = cfn_model.resources_by_type('AWS::IAM::User').select do |iam_user|
  #     iam_user.loginProfile['PasswordResetRequired'].nil? || iam_user.loginProfile['PasswordResetRequired'].to_s == 'false'
  #   end

  #   violating_iam_users.map(&:logical_resource_id)
  # end
end
