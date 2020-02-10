# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/enforce_reference_parameter'
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
    if [true, false].include?(user_pool.mfaConfiguration)
      true
    elsif [true, false].include?(param_value)
      true
    end
  end

  def keyword_uppercase?(user_pool)
    violating_key_words = %w[On on OFF Off off Optional optional]
    violating_key_words.include? user_pool.mfaConfiguration
  end

  def param_reference?(user_pool)
    violating_key_words = %w[On on OFF Off off Optional optional]
    ref_value = user_pool.mfaConfiguration.values[0]
    if user_pool.cfn_model.parameters[ref_value].default.nil?
    else
      param_value = user_pool.cfn_model.parameters[ref_value].default
      violating_key_words.include?(param_value) || yaml_reserved_keyword_boolean_conv?(user_pool, param_value)
    end
  end

  def violating_userpool?(user_pool)
    if user_pool.mfaConfiguration.class == Hash
      param_reference?(user_pool)
    else
      keyword_uppercase?(user_pool) || \
        yaml_reserved_keyword_boolean_conv?(user_pool)
    end
  end
end
