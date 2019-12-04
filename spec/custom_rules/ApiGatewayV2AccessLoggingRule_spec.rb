require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/ApiGatewayV2AccessLoggingRule'

describe ApiGatewayV2AccessLoggingRule do
  context 'Api Gateway V2 has no access logging configured' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/apigateway_accesslogging_v2/apigateway_with_no_access_logging.json')

      actual_logical_resource_ids = ApiGatewayV2AccessLoggingRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[ApiGatewayNoAccessLogging]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Api Gateway V2 has access logging configured' do
    it 'returns empty' do
      cfn_model = CfnParser.new.parse read_test_template('json/apigateway_accesslogging_v2/apigateway_with_access_logging.json')

      actual_logical_resource_ids = ApiGatewayV2AccessLoggingRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
