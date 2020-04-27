require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/DynamoDBBillingModeRule'

describe DynamoDBBillingModeRule do
  context 'dynamodb table without a billing mode or invalid billing mode' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/dynamodb/dynamodb_table_with_no_billing_mode.yaml'
      )

      actual_logical_resource_ids = DynamoDBBillingModeRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[DynamodbNoBillingMode DynamodbInvalidBillingMode]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'dynamodb table with provisioned billing mode' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/dynamodb/dynamodb_table_with_provisioned_billing_mode.yaml'
      )

      actual_logical_resource_ids = DynamoDBBillingModeRule.new.audit_impl cfn_model
      expected_logical_resource_ids = []

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'dynamodb table with pay per request billing mode' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/dynamodb/dynamodb_table_with_pay_per_use_billing_mode.yaml'
      )

      actual_logical_resource_ids = DynamoDBBillingModeRule.new.audit_impl cfn_model
      expected_logical_resource_ids = []

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
