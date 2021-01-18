require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/DAXClusterEncryptionRule'

describe DAXClusterEncryptionRule do
  context 'DynamoDB Accelerator Cluster without encryption' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/dax_cluster/dax_cluster_with_encryption_not_set.yaml'
      )

      actual_logical_resource_ids = DAXClusterEncryptionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[DAXCluster]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'DynamoDB Accelerator Cluster with encryption enabled' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/dax_cluster/dax_cluster_with_encryption_enabled.yaml'
      )

      actual_logical_resource_ids = DAXClusterEncryptionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = []

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'DynamoDB Accelerator Cluster with encryption disabled' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/dax_cluster/dax_cluster_with_encryption_disabled.yaml'
      )

      actual_logical_resource_ids = DAXClusterEncryptionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[DAXCluster]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
