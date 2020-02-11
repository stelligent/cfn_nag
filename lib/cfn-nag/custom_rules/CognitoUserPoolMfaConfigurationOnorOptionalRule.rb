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
    'F85'
  end

  def audit_impl(cfn_model)
    violating_userpools = cfn_model.resources_by_type('AWS::Cognito::UserPool').select do |userpool|
      violating_userpool?(userpool)
    end

    violating_userpools.map(&:logical_resource_id)
  end

  private

  def yaml_reserved_keyword_boolean_conv?(user_pool, param_value = '')
    if truthy?(user_pool.mfaConfiguration) || not_truthy?(user_pool.mfaConfiguration)
      true
    elsif truthy?(param_value) || not_truthy?(param_value)
      true
    end
  end

  def keyword_uppercase?(mfa_config_value)
    violating_key_words = %w[On on OFF Off off Optional optional]
    violating_key_words.include? mfa_config_value
  end

  def param_reference?(user_pool)
    ref_value = user_pool.mfaConfiguration.values[0]
    if user_pool.cfn_model.parameters[ref_value].default.nil?
    else
      param_value = user_pool.cfn_model.parameters[ref_value].default
      keyword_uppercase?(param_value) || yaml_reserved_keyword_boolean_conv?(user_pool, param_value)
    end
  end

  def violating_userpool?(user_pool)
    up_mfa = user_pool.mfaConfiguration
    if up_mfa.is_a?(Hash) && up_mfa.key?('Ref')
      param_reference?(user_pool)
    else
      keyword_uppercase?(up_mfa) || \
        yaml_reserved_keyword_boolean_conv?(user_pool)
    end
  end
end
