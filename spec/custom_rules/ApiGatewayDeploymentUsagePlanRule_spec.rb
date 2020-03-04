require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/ApiGatewayDeploymentUsagePlanRule'

describe ApiGatewayDeploymentUsagePlanRule do
  context "AWS::ApiGateway::UsagePlan exists for all AWS::ApiGateway::RestApi resources. " do
    it 'Returns an empty string' do
      parameters_json = <<-END
      {
        "Parameters": {
          "ApiGatewayDeploymentStageName3": "hardcoded-stage-3",
          "ApiGatewayDeploymentStageName4": "hardcoded-stage-4",
          "ApiGatewayDeploymentStageName5": "hardcoded-stage-5",
          "ApiGatewayDeploymentStageName6": "hardcoded-stage-6",
          "ApiGatewayDeploymentStageName7": "hardcoded-stage-7",
          "ApiGatewayDeploymentStageName8": "hardcoded-stage-8"
        }
      }
      END
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/api_gateway/api_gateway_usage_plan_exists_for_stages_created_by_deployments.yaml'
                                      ),
                                      parameter_values_json = parameters_json
                                      #parameter_values_json = '[]'

      actual_logical_resource_ids = ApiGatewayDeploymentUsagePlanRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  # context "AWS::ApiGateway::UsagePlan does not exist for API Stages created by API Deployment resources. " do
  #   it 'Returns offending logical resource ids.' do
  #     parameters_json = <<-END
  #     {
  #       "Parameters": {
  #         "ApiGatewayDeploymentStageName3": "stage-3",
  #         "ApiGatewayDeploymentStageName4": "stage-4",
  #         "ApiGatewayDeploymentStageName5": "stage-5",
  #         "ApiGatewayDeploymentStageName6": "stage-6",
  #         "ApiGatewayDeploymentStageName7": "stage-7",
  #         "ApiGatewayDeploymentStageName8": "stage-8"
  #       }
  #     }
  #     END
  #     cfn_model = CfnParser.new.parse read_test_template(
  #                                         'yaml/api_gateway/api_gateway_usage_plan_does_not_exist_for_stages_created_by_deployments.yaml'
  #                                     ),
  #                                     parameter_values_json=parameters_json
  #
  #     actual_logical_resource_ids = ApiGatewayDeploymentUsagePlanRule.new.audit_impl cfn_model
  #     expected_logical_resource_ids = %w[ApiGatewayDeployment1
  #                                        ApiGatewayDeployment2
  #                                        ApiGatewayDeployment3
  #                                        ApiGatewayDeployment4
  #                                        ApiGatewayDeployment5
  #                                        ApiGatewayDeployment6]
  #
  #     expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
  #   end
  # end
end