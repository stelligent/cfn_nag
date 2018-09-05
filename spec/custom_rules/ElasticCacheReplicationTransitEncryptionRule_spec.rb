require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/ElasticCacheReplicationTransitEncryptionRule'

describe ElasticCacheReplicationTransitEncryptionRule do
  context 'replication group without transit encryption enabled' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'json/elasticcache_replicationgroup/replication_group_without_transit_encrypt_enabled.json'
      )

      actual_logical_resource_ids = ElasticCacheReplicationTransitEncryptionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[BasicReplicationGroup]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
