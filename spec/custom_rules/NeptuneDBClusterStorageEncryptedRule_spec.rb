require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/NeptuneDBClusterStorageEncryptedRule'

describe NeptuneDBClusterStorageEncryptedRule do
  context 'Neptune database storage without encryption' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'json/neptune/with_no_encryption.json'
      )

      actual_logical_resource_ids = NeptuneDBClusterStorageEncryptedRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[NeptuneDBCluster]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Neptune database storage with encryption' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template('json/neptune/with_encryption.json')

      actual_logical_resource_ids = NeptuneDBClusterStorageEncryptedRule.new.audit_impl cfn_model
      expected_logical_resource_ids = []

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Neptune database storage encryption set to false string' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/neptune/with_encryption_false_string.json')

      actual_logical_resource_ids = NeptuneDBClusterStorageEncryptedRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[NeptuneDBCluster]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Neptune database storage encryption set to false boolean' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/neptune/with_encryption_false_boolean.json')

      actual_logical_resource_ids = NeptuneDBClusterStorageEncryptedRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[NeptuneDBCluster]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
