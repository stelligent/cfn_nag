# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/truthy'
require 'cfn-nag/util/parameter_reference_and_default_value'
require_relative 'base'

class CognitoUserPoolMfaConfigurationOnorOptionalRule < BaseRule
  def rule_text
    "AWS Cognito UserPool should have MfaConfiguration set to 'ON' (MUST be wrapped in quotes) or at least 'OPTIONAL'"
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F51'
  end

  def audit_impl(cfn_model)
    violating_userpools = cfn_model.resources_by_type('AWS::Cognito::UserPool').select do |userpool|
      violating_userpool?(userpool)
    end

    violating_userpools.map(&:logical_resource_id)
  end

  private

  def yaml_reserved_keyword_boolean?(property_value)
    truthy?(property_value) || not_truthy?(property_value)
  end

  def violating_keywords?(mfa_config_value)
    valid_keywords = %w[ON OPTIONAL]
    !valid_keywords.include? mfa_config_value
  end

  def violations?(mfa_config_value)
    violating_keywords?(mfa_config_value) || \
      yaml_reserved_keyword_boolean?(mfa_config_value)
  end

  def violating_userpool?(user_pool)
    up_mfa = user_pool.mfaConfiguration
    if property_a_param_ref?(user_pool, up_mfa)
      prop_default_value = get_default_param_value(user_pool, up_mfa)
      if prop_default_value.nil?
      else
        violations?(prop_default_value)
      end
    else
      violations?(up_mfa)
    end
  end
end
