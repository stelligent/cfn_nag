require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/DynamoDBBackupRule'

describe DynamoDBBackupRule do
  context 'dynamodb table without backup' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/dynamodb/dynamodb_table_with_no_backup_enabled.yaml'
      )

      actual_logical_resource_ids = DynamoDBBackupRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[DynamodbNoBackupEnabled DynamodbNoBackupEnabled2]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'dynamodb table with backup enabled' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/dynamodb/dynamodb_table_with_backup_enabled.yaml'
      )

      actual_logical_resource_ids = DynamoDBBackupRule.new.audit_impl cfn_model
      expected_logical_resource_ids = []

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
