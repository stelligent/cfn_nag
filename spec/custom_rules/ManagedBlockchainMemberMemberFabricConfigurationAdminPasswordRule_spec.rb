require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/ManagedBlockchainMemberMemberFabricConfigurationAdminPasswordRule'

describe ManagedBlockchainMemberMemberFabricConfigurationAdminPasswordRule, :rule do
  context 'ManagedBlockchain Member MemberFabricConfiguration AdminPassword not set' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/managedblockchain_member/' \
        'managedblockchain_member_member_fabric_configuration_admin_password_not_set.yaml'
      )

      actual_logical_resource_ids =
        ManagedBlockchainMemberMemberFabricConfigurationAdminPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'ManagedBlockchain Member MemberFabricConfiguration AdminPassword parameter with NoEcho' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/managedblockchain_member/' \
        'managedblockchain_member_member_fabric_configuration_admin_password_parameter_with_noecho.yaml'
      )

      actual_logical_resource_ids =
        ManagedBlockchainMemberMemberFabricConfigurationAdminPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'ManagedBlockchain Member MemberFabricConfiguration AdminPassword parameter with NoEcho and Default value' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/managedblockchain_member/' \
        'managedblockchain_member_member_fabric_configuration_admin_password_parameter_with_noecho_and_default_value.yaml'
      )

      actual_logical_resource_ids =
        ManagedBlockchainMemberMemberFabricConfigurationAdminPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[ManagedBlockchainMember]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'ManagedBlockchain Member MemberFabricConfiguration AdminPassword parameter as a literal in plaintext' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/managedblockchain_member/' \
        'managedblockchain_member_member_fabric_configuration_admin_password_parameter_as_a_literal_in_plaintext.yaml'
      )

      actual_logical_resource_ids =
        ManagedBlockchainMemberMemberFabricConfigurationAdminPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[ManagedBlockchainMember]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'ManagedBlockchain Member MemberFabricConfiguration AdminPassword as a literal in plaintext' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/managedblockchain_member/' \
        'managedblockchain_member_member_fabric_configuration_admin_password_as_a_literal_in_plaintext.yaml'
      )

      actual_logical_resource_ids =
        ManagedBlockchainMemberMemberFabricConfigurationAdminPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[ManagedBlockchainMember]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'ManagedBlockchain Member MemberFabricConfiguration AdminPassword from Secrets Manager' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/managedblockchain_member/' \
        'managedblockchain_member_member_fabric_configuration_admin_password_from_secrets_manager.yaml'
      )

      actual_logical_resource_ids =
        ManagedBlockchainMemberMemberFabricConfigurationAdminPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'ManagedBlockchain Member MemberFabricConfiguration AdminPassword from Secure Systems Manager' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/managedblockchain_member/' \
        'managedblockchain_member_member_fabric_configuration_admin_password_from_secure_systems_manager.yaml'
      )

      actual_logical_resource_ids =
        ManagedBlockchainMemberMemberFabricConfigurationAdminPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'ManagedBlockchain Member MemberFabricConfiguration AdminPassword from Systems Manager' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/managedblockchain_member/' \
        'managedblockchain_member_member_fabric_configuration_admin_password_from_systems_manager.yaml'
      )

      actual_logical_resource_ids =
        ManagedBlockchainMemberMemberFabricConfigurationAdminPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[ManagedBlockchainMember]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
