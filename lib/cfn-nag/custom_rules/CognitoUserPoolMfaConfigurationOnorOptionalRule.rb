# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/truthy'
require_relative 'base'

class CognitoUserPoolMfaConfigurationOnorOptionalRule < BaseRule
  def rule_text
    "AWS Cognito UserPool should have MfaConfiguration set to 'ON' (MUST be wrapped in quotes) or at least 'OPTIONAL'"
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F78'
  end

  def audit_impl(cfn_model)
    violating_userpools = cfn_model.resources_by_type('AWS::Cognito::UserPool').select do |userpool|
      violating_userpool?(userpool)
    end

    violating_userpools.map(&:logical_resource_id)
  end

  private

  def violating_userpool?(user_pool)
    user_pool.mfaConfiguration.to_s.casecmp('off').zero?
  end
end
