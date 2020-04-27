require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/DynamoDBEncryptionRule'

describe DynamoDBEncryptionRule do
  context 'dynamodb table without encryption' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/dynamodb/dynamodb_table_with_no_encryption.yaml'
      )

      actual_logical_resource_ids = DynamoDBEncryptionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[DynamodbNoEncryption DynamodbEncryptionDisabled]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'dynamodb table with encryption enabled' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/dynamodb/dynamodb_table_with_encryption_enabled.yaml'
      )

      actual_logical_resource_ids = DynamoDBEncryptionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = []

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
