require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/ApiGatewayRestApiUsagePlanRule'

describe ApiGatewayRestApiUsagePlanRule do
  context "AWS::ApiGateway::UsagePlan exists for all AWS::ApiGateway::RestApi resources. " do
    it 'Returns an empty string' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/api_gateway/api_gateway_usage_plan_exists_for_rest_apis.yaml'
                                      )

      actual_logical_resource_ids = ApiGatewayRestApiUsagePlanRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context "AWS::ApiGateway::UsagePlan does not exist for AWS::ApiGateway::RestApi resources. " do
    it 'Returns offending logical resource ids.' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/api_gateway/api_gateway_usage_plan_does_not_exist_for_rest_apis.yaml'
                                      )

      actual_logical_resource_ids = ApiGatewayRestApiUsagePlanRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[ApiGatewayRestApi1 ApiGatewayRestApi2 ApiGatewayRestApi3 ApiGatewayRestApi4]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end