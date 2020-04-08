require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/CloudfrontMinimumProtocolVersionRule'

describe CloudfrontMinimumProtocolVersionRule do
  context 'distribution without tls config' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/cloudfront_distribution/cloudfront_with_no_tls_config.json')

      actual_logical_resource_ids = CloudfrontMinimumProtocolVersionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[ApiGatewayWithNoTLSConfg]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'distribution without bad tls or default tls config' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/cloudfront_distribution/cloudfront_with_tls_10.json')

      actual_logical_resource_ids = CloudfrontMinimumProtocolVersionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = ["ApiGatewayWithSSLv3", "ApiGatewayWithTLS10", "ApiGatewayWithTLS11", "ApiGatewayWithTLS12016", "ApiGatewayWithDefaultTLS"]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'distribution with minimum tls 1.2 and not override by CloudFrontDefaultCertificate Usage' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/cloudfront_distribution/cloudfront_with_tls_12.json')

      actual_logical_resource_ids = CloudfrontMinimumProtocolVersionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = ["ApiGatewayWithTls12OverridebyCloudFrontDefaultCertificateUsage"]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

end
