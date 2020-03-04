require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/ApiGatewayStageUsagePlanRule'

describe ApiGatewayStageUsagePlanRule do
  context "AWS::ApiGateway::UsagePlan exists for all AWS::ApiGateway::Stage resources. " do
    it 'Returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/api_gateway/api_gateway_usage_plan_exists_for_api_stage.yaml'
                                      )

      actual_logical_resource_ids = ApiGatewayStageUsagePlanRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context "AWS::ApiGateway::UsagePlan does not exist for AWS::ApiGateway::Stage resources. " do
    it 'Returns offending logical resource ids.' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/api_gateway/api_gateway_usage_plan_does_not_exist_for_api_stage.yaml'
                                      )

      actual_logical_resource_ids = ApiGatewayStageUsagePlanRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[ApiGatewayStage1 ApiGatewayStage2 ApiGatewayStage3 ApiGatewayStage4]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context "AWS::ApiGateway::Stage resource is associated with two AWS::ApiGateway::UsagePlan resources. " do
    it 'Returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/api_gateway/api_gateway_stage_is_associated_with_two_usage_plans.yaml'
                                      )

      actual_logical_resource_ids = ApiGatewayStageUsagePlanRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end