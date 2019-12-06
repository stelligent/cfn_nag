require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/AlexaASKSkillAuthenticationConfigurationRefreshTokenRule'

describe AlexaASKSkillAuthenticationConfigurationRefreshTokenRule, :rule do
  context 'Alexa ASK Skill AuthenticationConfiguration RefreshToken not set' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/alexa_ask_skill/' \
        'alexa_ask_skill_authentication_configuration_refresh_token_not_set.yaml'
      )

      actual_logical_resource_ids =
        AlexaASKSkillAuthenticationConfigurationRefreshTokenRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Alexa ASK Skill AuthenticationConfiguration RefreshToken parameter with NoEcho' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/alexa_ask_skill/' \
        'alexa_ask_skill_authentication_configuration_refresh_token_parameter_with_noecho.yaml'
      )

      actual_logical_resource_ids =
        AlexaASKSkillAuthenticationConfigurationRefreshTokenRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Alexa ASK Skill AuthenticationConfiguration RefreshToken parameter with NoEcho and Default value' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/alexa_ask_skill/' \
        'alexa_ask_skill_authentication_configuration_refresh_token_parameter_with_noecho_and_default_value.yaml'
      )

      actual_logical_resource_ids =
        AlexaASKSkillAuthenticationConfigurationRefreshTokenRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[AlexaASKSkill]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Alexa ASK Skill AuthenticationConfiguration RefreshToken parameter as a literal in plaintext' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/alexa_ask_skill/' \
        'alexa_ask_skill_authentication_configuration_refresh_token_parameter_as_a_literal_in_plaintext.yaml'
      )

      actual_logical_resource_ids =
        AlexaASKSkillAuthenticationConfigurationRefreshTokenRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[AlexaASKSkill]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Alexa ASK Skill AuthenticationConfiguration RefreshToken as a literal in plaintext' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/alexa_ask_skill/' \
        'alexa_ask_skill_authentication_configuration_refresh_token_as_a_literal_in_plaintext.yaml'
      )

      actual_logical_resource_ids =
        AlexaASKSkillAuthenticationConfigurationRefreshTokenRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[AlexaASKSkill]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Alexa ASK Skill AuthenticationConfiguration RefreshToken from Secrets Manager' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/alexa_ask_skill/' \
        'alexa_ask_skill_authentication_configuration_refresh_token_from_secrets_manager.yaml'
      )

      actual_logical_resource_ids =
        AlexaASKSkillAuthenticationConfigurationRefreshTokenRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Alexa ASK Skill AuthenticationConfiguration RefreshToken from Secure Systems Manager' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/alexa_ask_skill/' \
        'alexa_ask_skill_authentication_configuration_refresh_token_from_secure_systems_manager.yaml'
      )

      actual_logical_resource_ids =
        AlexaASKSkillAuthenticationConfigurationRefreshTokenRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Alexa ASK Skill AuthenticationConfiguration RefreshToken from Systems Manager' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/alexa_ask_skill/' \
        'alexa_ask_skill_authentication_configuration_refresh_token_from_systems_manager.yaml'
      )

      actual_logical_resource_ids =
        AlexaASKSkillAuthenticationConfigurationRefreshTokenRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[AlexaASKSkill]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
