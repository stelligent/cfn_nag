require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/ApiGatewaySecurityPolicyRule'

describe ApiGatewaySecurityPolicyRule do
  context 'Api Gateway has not TLS 1.2 configured since it missing SecurityPolicy' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/apigateway_securitypolicy/apigateway_without_securitypolicy.json')

      actual_logical_resource_ids = ApiGatewaySecurityPolicyRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[ApiGatewayWithoutSecurityPolicy]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Api Gateway have TLS 1.0 enabled' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/apigateway_securitypolicy/apigateway_with_tls_10.json')

      actual_logical_resource_ids = ApiGatewaySecurityPolicyRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[ApiGatewayWithTLS10]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Api Gateway have TLS 1.2 enabled' do
    it 'returns empty' do
      cfn_model = CfnParser.new.parse read_test_template('json/apigateway_securitypolicy/apigateway_with_tls_12.json')

      actual_logical_resource_ids = ApiGatewaySecurityPolicyRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
