require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/EMRSecurityConfigurationEncryptionsEnabledAndConfiguredRule'

describe EMRSecurityConfigurationEncryptionsEnabledAndConfiguredRule do
  describe 'AWS::EMR::SecurityConfiguration' do
    context 'when both at rest and in transit encryptions are enabled and configured correctly' do
      it 'does not return an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('yaml/emr_cluster/emr_cluster_with_properly_configured_encryption.yml')
        actual_logical_resource_ids = EMRSecurityConfigurationEncryptionsEnabledAndConfiguredRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end

    context 'when either at rest or in transit encryptions are disabled' do
      it 'returns an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('yaml/emr_cluster/emr_cluster_with_disabled_encryption_options.yml')
        actual_logical_resource_ids = EMRSecurityConfigurationEncryptionsEnabledAndConfiguredRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq %w[
          EMRSecurityConfigWithDisabledAtRestEncryption
          EMRSecurityConfigWithDisabledInTransitEncryption
        ]
      end
    end

    context 'when at rest encryption is enabled but misconfigured' do
      it 'returns an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('yaml/emr_cluster/emr_cluster_with_misconfigured_at_rest_encryption.yml')
        actual_logical_resource_ids = EMRSecurityConfigurationEncryptionsEnabledAndConfiguredRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq %w[EMRSecurityConfigWithMisconfiguredAtRestEncryption]
      end
    end

    context 'when in transit encryption is enabled but misconfigured' do
      it 'returns an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('yaml/emr_cluster/emr_cluster_with_misconfigured_in_transit_encryption.yml')
        actual_logical_resource_ids = EMRSecurityConfigurationEncryptionsEnabledAndConfiguredRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq %w[EMRSecurityConfigWithMisconfiguredInTransitEncryption]
      end
    end
  end
end
