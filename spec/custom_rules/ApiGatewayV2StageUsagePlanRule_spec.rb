require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/ApiGatewayV2StageUsagePlanRule'

describe ApiGatewayV2StageUsagePlanRule do
  context "AWS::ApiGateway::UsagePlan exists for all AWS::ApiGatewayV2::Stage resources. " do
    it 'Returns an empty string' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/api_gateway/api_gateway_usage_plan_exists_for_api_v2_stage.yaml'
                                      )

      actual_logical_resource_ids = ApiGatewayV2StageUsagePlanRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context "AWS::ApiGateway::UsagePlan does not exist for AWS::ApiGatewayV2::Stage resources. " do
    it 'Returns offending logical resource ids.' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/api_gateway/api_gateway_usage_plan_does_not_exist_for_api_v2_stage.yaml'
                                      )

      actual_logical_resource_ids = ApiGatewayV2StageUsagePlanRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[ApiGatewayV2Stage1 ApiGatewayV2Stage2 ApiGatewayV2Stage3 ApiGatewayV2Stage4]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end