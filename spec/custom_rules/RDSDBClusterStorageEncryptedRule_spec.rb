require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/RDSDBClusterStorageEncryptedRule'

describe RDSDBClusterStorageEncryptedRule do
  context 'DB Cluster without encryption' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'json/rds_instance/db_cluster_with_no_encryption.json'
      )

      actual_logical_resource_ids = RDSDBClusterStorageEncryptedRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[RDSCluster]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'DB Cluster with encryption' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template('json/rds_instance/db_cluster_with_encryption.json')

      actual_logical_resource_ids = RDSDBClusterStorageEncryptedRule.new.audit_impl cfn_model
      expected_logical_resource_ids = []

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'DB Cluster with encryption set to false string' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/rds_instance/db_cluster_with_encryption_false.json')

      actual_logical_resource_ids = RDSDBClusterStorageEncryptedRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[RDSCluster]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'DB Cluster with encryption set to false boolean' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/rds_instance/db_cluster_with_encryption_false_boolean.json')

      actual_logical_resource_ids = RDSDBClusterStorageEncryptedRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[RDSCluster]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
