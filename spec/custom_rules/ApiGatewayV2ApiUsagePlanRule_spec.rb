require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/ApiGatewayV2ApiUsagePlanRule'

describe ApiGatewayV2ApiUsagePlanRule do
  context "AWS::ApiGateway::UsagePlan exists for all AWS::ApiGatewayV2::Api resources (with ProtocolType: WEBSOCKET). " do
    it 'Returns an empty string' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/api_gateway/api_gateway_usage_plan_exists_for_v2_apis.yaml'
                                      )

      actual_logical_resource_ids = ApiGatewayV2ApiUsagePlanRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context "AWS::ApiGateway::UsagePlan does not exist for AWS::ApiGatewayV2::Api resources (with ProtocolType: WEBSOCKET). " do
    it 'Returns offending logical resource ids.' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/api_gateway/api_gateway_usage_plan_does_not_exist_for_v2_apis.yaml'
                                      )

      actual_logical_resource_ids = ApiGatewayV2ApiUsagePlanRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[ApiGatewayV2Api1 ApiGatewayV2Api2 ApiGatewayV2Api3 ApiGatewayV2Api4]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context "AWS::ApiGateway::UsagePlan does not exist for AWS::ApiGatewayV2::Api resources (with ProtocolType: HTTP). " do
    it 'Returns an empty string' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/api_gateway/api_gateway_usage_plan_does_not_exist_for_v2_apis_protocol_http.yaml'
                                      )

      actual_logical_resource_ids = ApiGatewayV2ApiUsagePlanRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end