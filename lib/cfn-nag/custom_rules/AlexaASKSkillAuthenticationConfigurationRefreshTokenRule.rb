# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/enforce_reference_parameter'
require 'cfn-nag/util/enforce_string_or_dynamic_reference'
require_relative 'base'

class AlexaASKSkillAuthenticationConfigurationRefreshTokenRule < BaseRule
  def rule_text
    'Alexa ASK Skill AuthenticationConfiguration RefreshToken must not be ' \
    'a plaintext string or a Ref to a NoEcho Parameter with a Default value.'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F75'
  end

  def audit_impl(cfn_model)
    ask_skills = cfn_model.resources_by_type('Alexa::ASK::Skill')
    violating_skills = ask_skills.select do |skill|
      refresh_token = skill.authenticationConfiguration['RefreshToken']
      if refresh_token.nil?
        false
      else
        insecure_parameter?(cfn_model, refresh_token) ||
          insecure_string_or_dynamic_reference?(cfn_model, refresh_token)
      end
    end

    violating_skills.map(&:logical_resource_id)
  end
end
