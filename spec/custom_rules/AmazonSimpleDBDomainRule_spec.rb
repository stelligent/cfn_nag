require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/AmazonSimpleDBDomainRule'

describe AmazonSimpleDBDomainRule do
  context 'SimpleDB Domain is a declared resource' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/amazon_simpledb/simpledb_domain_resource.yml'
      )

      actual_logical_resource_ids = AmazonSimpleDBDomainRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[NewSimpleDB]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'SimpleDB Domain is not a declared resource' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/amazon_simpledb/no_simpledb_domain_resource.yml'
      )

      actual_logical_resource_ids = AmazonSimpleDBDomainRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
