require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/MediaLiveChannelOutputDestinationSettingsPasswordParamRule'

describe MediaLiveChannelOutputDestinationSettingsPasswordParamRule, :rule do
  context 'MediaLive Channel OutputDestinationSettings PasswordParam not set' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/medialive_channel/' \
        'media_live_channel_output_destination_settings_password_param_not_set.yaml'
      )

      actual_logical_resource_ids =
        MediaLiveChannelOutputDestinationSettingsPasswordParamRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'MediaLive Channel OutputDestinationSettings PasswordParam parameter with NoEcho' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/medialive_channel/' \
        'media_live_channel_output_destination_settings_password_param_parameter_with_noecho.yaml'
      )

      actual_logical_resource_ids =
        MediaLiveChannelOutputDestinationSettingsPasswordParamRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'MediaLive Channel OutputDestinationSettings PasswordParam parameter with NoEcho and Default value' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/medialive_channel/' \
        'media_live_channel_output_destination_settings_password_param_parameter_with_noecho_and_default_value.yaml'
      )

      actual_logical_resource_ids =
        MediaLiveChannelOutputDestinationSettingsPasswordParamRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[MediaLiveChannel]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'MediaLive Channel OutputDestinationSettings PasswordParam parameter as a literal in plaintext' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/medialive_channel/' \
        'media_live_channel_output_destination_settings_password_param_parameter_as_a_literal_in_plaintext.yaml'
      )

      actual_logical_resource_ids =
        MediaLiveChannelOutputDestinationSettingsPasswordParamRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[MediaLiveChannel]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'MediaLive Channel OutputDestinationSettings PasswordParam as a literal in plaintext' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/medialive_channel/' \
        'media_live_channel_output_destination_settings_password_param_as_a_literal_in_plaintext.yaml'
      )

      actual_logical_resource_ids =
        MediaLiveChannelOutputDestinationSettingsPasswordParamRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[MediaLiveChannel]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'MediaLive Channel OutputDestinationSettings PasswordParam from Secrets Manager' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/medialive_channel/' \
        'media_live_channel_output_destination_settings_password_param_from_secrets_manager.yaml'
      )

      actual_logical_resource_ids =
        MediaLiveChannelOutputDestinationSettingsPasswordParamRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'MediaLive Channel OutputDestinationSettings PasswordParam from Secure Systems Manager' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/medialive_channel/' \
        'media_live_channel_output_destination_settings_password_param_from_secure_systems_manager.yaml'
      )

      actual_logical_resource_ids =
        MediaLiveChannelOutputDestinationSettingsPasswordParamRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'MediaLive Channel OutputDestinationSettings PasswordParam from Systems Manager' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/medialive_channel/' \
        'media_live_channel_output_destination_settings_password_param_from_systems_manager.yaml'
      )

      actual_logical_resource_ids =
        MediaLiveChannelOutputDestinationSettingsPasswordParamRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[MediaLiveChannel]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
