require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/ApiGatewayCacheEncryptedRule'

describe ApiGatewayCacheEncryptedRule do
  context 'Api Gateway has cache encryption enabled' do
    it 'returns no violating resources' do
      cfn_model = CfnParser.new.parse read_test_template('json/apigateway_cacheencrypted/apigateway_with_cache_encryption_enabled.json')

      actual_logical_resource_ids = ApiGatewayCacheEncryptedRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Api Gateway has no cache configured' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/apigateway_cacheencrypted/apigateway_with_no_cache_enabled_missing_stagedescription.json')

      actual_logical_resource_ids = ApiGatewayCacheEncryptedRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Api Gateway with no cache encryption enabled' do
    it 'returns empty' do
      cfn_model = CfnParser.new.parse read_test_template('json/apigateway_cacheencrypted/apigateway_with_no_cache_encryption.json')

      actual_logical_resource_ids = ApiGatewayCacheEncryptedRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[ApiGatewayWithCacheEncryptionDisabled ApiGatewayWithDefaultCacheEncryption]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

end
