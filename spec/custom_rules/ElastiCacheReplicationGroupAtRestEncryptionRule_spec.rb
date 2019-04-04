require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/ElastiCacheReplicationGroupAtRestEncryptionRule'

describe ElastiCacheReplicationGroupAtRestEncryptionRule do
  context 'Replication Group without encryption' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'json/elasticache/replication_group_with_no_encryption.json'
      )

      actual_logical_resource_ids = ElastiCacheReplicationGroupAtRestEncryptionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[BasicReplicationGroup]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Replication Group with encryption' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template('json/elasticache/replication_group_with_encryption.json')

      actual_logical_resource_ids = ElastiCacheReplicationGroupAtRestEncryptionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = []

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Replication Group with encryption set to false string' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/elasticache/replication_group_with_encryption_false.json')

      actual_logical_resource_ids = ElastiCacheReplicationGroupAtRestEncryptionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[BasicReplicationGroup]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Replication Group with encryption set to false boolean' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/elasticache/replication_group_with_encryption_false_boolean.json')

      actual_logical_resource_ids = ElastiCacheReplicationGroupAtRestEncryptionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[BasicReplicationGroup]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
