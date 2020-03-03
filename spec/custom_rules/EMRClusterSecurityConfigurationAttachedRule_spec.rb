require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/EMRClusterSecurityConfigurationAttachedRule'

describe EMRClusterSecurityConfigurationAttachedRule do
  describe 'AWS::EMR::Cluster' do
    context 'when SecurityConfiguration property is set and config exists in the same template' do
      it 'does not return an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('yaml/emr_cluster/emr_cluster_with_properly_configured_encryption.yml')
        actual_logical_resource_ids = EMRClusterSecurityConfigurationAttachedRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end
    context 'when SecurityConfiguration property is not set or is external' do
      it 'returns an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('yaml/emr_cluster/emr_cluster_without_security_configuration.yml')
        actual_logical_resource_ids = EMRClusterSecurityConfigurationAttachedRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq %w[
          EMRClusterWithoutSecurityConfiguration
          EMRClusterWithExternalSecurityConfiguration
        ]
      end
    end
  end
end
