require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/ApiGatewayAccessLoggingRule'

describe ApiGatewayAccessLoggingRule do
  context 'Api Gateway has no access logging configured since it missing stagedescription' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/apigateway_accesslogging/apigateway_with_no_access_logging_missing_stagedescription.json')

      actual_logical_resource_ids = ApiGatewayAccessLoggingRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[ApiGatewayNoAccessLogging]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Api Gateway has no access logging configured' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/apigateway_accesslogging/apigateway_with_no_access_logging.json')

      actual_logical_resource_ids = ApiGatewayAccessLoggingRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[ApiGatewayNoAccessLogging]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Api Gateway should has access logging configured' do
    it 'returns empty' do
      cfn_model = CfnParser.new.parse read_test_template('json/apigateway_accesslogging/apigateway_with_access_logging.json')

      actual_logical_resource_ids = ApiGatewayAccessLoggingRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

 context 'Api Gateway with stage access logging configured' do
    it 'returns empty' do
      cfn_model = CfnParser.new.parse read_test_template('json/apigateway_accesslogging/apigateway_with_stage_access_logging.json')

      actual_logical_resource_ids = ApiGatewayAccessLoggingRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  
  
end
