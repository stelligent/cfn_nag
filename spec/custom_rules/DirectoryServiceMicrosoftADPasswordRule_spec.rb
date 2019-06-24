require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/DirectoryServiceMicrosoftADPasswordRule'

describe DirectoryServiceMicrosoftADPasswordRule, :rule do
  context 'Directory Service Microsoft AD without password set' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/directory_service_microsoft_ad/' \
        'directory_service_microsoft_ad_no_password.yml'
      )

      actual_logical_resource_ids =
        DirectoryServiceMicrosoftADPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Directory Service Microsoft AD with parameter password with NoEcho' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/directory_service_microsoft_ad/' \
        'directory_service_microsoft_ad_password_parameter_noecho.yml'
      )

      actual_logical_resource_ids =
        DirectoryServiceMicrosoftADPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Directory Service Microsoft AD with literal password in plaintext' do
    it 'returns offending logical resource id for offending ' \
      'Directory Service Microsoft AD' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/directory_service_microsoft_ad/' \
        'directory_service_microsoft_ad_password_plaintext.yml'
      )

      actual_logical_resource_ids =
        DirectoryServiceMicrosoftADPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[MicrosoftAD]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Directory Service Microsoft AD with parameter password with ' \
    'NoEcho that has Default value' do
    it 'returns offending logical resource id for offending ' \
      'Directory Service Microsoft AD' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/directory_service_microsoft_ad/' \
        'directory_service_microsoft_ad_password_parameter_noecho_with_default.yml'
      )
      actual_logical_resource_ids =
        DirectoryServiceMicrosoftADPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[MicrosoftAD]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Directory Service Microsoft AD password from Secrets Manager' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/directory_service_microsoft_ad/' \
        'directory_service_microsoft_ad_password_secrets_manager.yml'
      )
      actual_logical_resource_ids =
        DirectoryServiceMicrosoftADPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Directory Service Microsoft AD password from Secure Systems Manager' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/directory_service_microsoft_ad/' \
        'directory_service_microsoft_ad_password_ssm-secure.yml'
      )
      actual_logical_resource_ids =
        DirectoryServiceMicrosoftADPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Directory Service Microsoft AD password from Systems Manager' do
    it 'returns offending logical resource id for offending ' \
      'Directory Service Microsoft AD' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/directory_service_microsoft_ad/' \
        'directory_service_microsoft_ad_password_ssm.yml'
      )
      actual_logical_resource_ids =
        DirectoryServiceMicrosoftADPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[MicrosoftAD]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
