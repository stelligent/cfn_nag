require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/ApiGatewayDeploymentUsagePlanRule'

describe ApiGatewayDeploymentUsagePlanRule do
  context "AWS::ApiGateway::UsagePlan exists for all AWS::ApiGateway::Deployment resources where the Deployment is creating a Stage. " do
    it 'Returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/api_gateway/api_gateway_usage_plan_exists_for_api_deployments_that_create_stages.yaml'
                                      )

      actual_logical_resource_ids = ApiGatewayDeploymentUsagePlanRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context "AWS::ApiGateway::UsagePlan does not exist for  AWS::ApiGateway::Deployment resources where the Deployment is creating a Stage. " do
    it 'Returns offending logical resource ids.' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/api_gateway/api_gateway_usage_plan_does_not_exists_for_api_deployments_that_create_stages.yaml'
                                      )

      actual_logical_resource_ids = ApiGatewayDeploymentUsagePlanRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[ApiGatewayDeployment1 ApiGatewayDeployment2 ApiGatewayDeployment3]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  #
  context "AWS::ApiGateway::Deployment does NOT create a stage but is instead referenced in an API Stage that DOES have a UsagePlan "do
    it 'Returns an empty list.' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/api_gateway/api_gateway_usage_plan_exists_for_api_deployments_that_are_refd_in_stages.yaml'
                                      )

      actual_logical_resource_ids = ApiGatewayDeploymentUsagePlanRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context "AWS::ApiGateway::Deployment does NOT create a stage but is instead referenced in an API Stage that DOES NOT have a UsagePlan "do
    it 'Returns offending logical resource ids.' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/api_gateway/api_gateway_usage_plan_does_not_exist_for_api_deployments_that_are_refd_in_stages.yaml'
                                      )

      actual_logical_resource_ids = ApiGatewayDeploymentUsagePlanRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[ApiGatewayDeployment3 ApiGatewayDeployment4]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end