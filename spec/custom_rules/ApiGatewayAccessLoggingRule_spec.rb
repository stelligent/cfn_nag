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

  context 'Api Gateway Deployment does not have AccessLogSetting defined but its referenced in a AWS::ApiGateway::Stage ' \
    'resource that DOES have AccessLogSetting defined.'do
    it 'returns empty' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/api_gateway/api_gateway_deployment_with_no_access_logging_but_refd_in_stage_with_logging.yaml'
                                      )

      actual_logical_resource_ids = ApiGatewayAccessLoggingRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Api Gateway Deployment does not have AccessLogSetting defined and is not referenced in a AWS::ApiGateway::Stage. ' do
    it 'Returns offending logical resource ids' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/api_gateway/api_gateway_deployment_with_no_access_logging_and_not_refd_in_stage.yaml'
                                      )

      actual_logical_resource_ids = ApiGatewayAccessLoggingRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[ApiGatewayDeployment1 ApiGatewayDeployment2]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Api Gateway Deployment does have StageDescription > AccessLogSetting defined. ' do
    it 'Returns empty' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/api_gateway/api_gateway_deployment_with_access_log_setting.yaml'
                                      )

      actual_logical_resource_ids = ApiGatewayAccessLoggingRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Api Gateway Deployment does not have StageDescription defined and is referenced in a Stage that does NOT have AccessLogSetting defined. ' do
    it 'Returns offending logical resource ids' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/api_gateway/api_gateway_deployment_with_no_access_logging_and_refd_in_stage_with_no_logging.yaml'
                                      )

      actual_logical_resource_ids = ApiGatewayAccessLoggingRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
