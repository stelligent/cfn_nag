require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/RDSDBInstanceStorageEncryptedRule'

describe RDSDBInstanceStorageEncryptedRule do

  context 'DB Instance with cluster identifier' do
    it 'inherits the cluster\'s encryption, and therefore passes' do
      cfn_model = CfnParser.new.parse read_test_template(
        'json/rds_instance/db_instance_with_clusterid_and_encryption_false.json'
      )

      actual_logical_resource_ids = RDSDBInstanceStorageEncryptedRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'DB Instance without encryption' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'json/rds_instance/db_instance_with_no_encryption.json'
      )

      actual_logical_resource_ids = RDSDBInstanceStorageEncryptedRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[MyDB]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'DB Instance with encryption' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template('json/rds_instance/db_instance_with_encryption.json')

      actual_logical_resource_ids = RDSDBInstanceStorageEncryptedRule.new.audit_impl cfn_model
      expected_logical_resource_ids = []

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'DB Instance with encryption set to false string' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/rds_instance/db_instance_with_encryption_false.json')

      actual_logical_resource_ids = RDSDBInstanceStorageEncryptedRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[MyDB]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'DB Instance with encryption set to false boolean' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/rds_instance/db_instance_with_encryption_false_boolean.json')

      actual_logical_resource_ids = RDSDBInstanceStorageEncryptedRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[MyDB]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
