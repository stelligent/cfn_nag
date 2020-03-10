require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/ApiGatewayStageAccessLoggingRule'

describe ApiGatewayStageAccessLoggingRule do
  context "An AWS::ApiGateway::Stage resource does not have AccessLogSetting defined. " do
    it 'Returns offending logical resource ids.' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/api_gateway/api_gateway_stage_does_not_have_access_logging.yaml'
                                      )

      actual_logical_resource_ids = ApiGatewayStageAccessLoggingRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[ApiGatewayStage1 ApiGatewayStage2]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context "An AWS::ApiGateway::Stage resource does have AccessLogSetting defined. " do
    it 'Returns an empty list.' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/api_gateway/api_gateway_stage_does_have_access_logging.yaml'
                                      )

      actual_logical_resource_ids = ApiGatewayStageAccessLoggingRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end