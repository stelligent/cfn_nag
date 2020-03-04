require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/ApiGatewayMethodAuthorizationTypeRule'

describe ApiGatewayMethodAuthorizationTypeRule do
  context "AWS::ApiGateway::Method has AuthorizationType set to NONE. " do
    it 'Returns offending logical resource ids.' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/api_gateway/api_gateway_method_authorization_type_none.yaml'
                                      )

      actual_logical_resource_ids = ApiGatewayMethodAuthorizationTypeRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[ApiGatewayMethod1 ApiGatewayMethod2 ApiGatewayMethod3]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context "AWS::ApiGateway::Method has AuthorizationType set to any of the valid values. " do
    it 'Returns an empty list.' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/api_gateway/api_gateway_method_authorization_type_valid_values.yaml'
                                      )

      actual_logical_resource_ids = ApiGatewayMethodAuthorizationTypeRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context "AWS::ApiGateway::Method has AuthorizationType set to NONE with Default value param refs. " do
    it 'Returns offending logical resource ids.' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/api_gateway/api_gateway_method_authorization_type_none_with_param_refs.yaml',
                                      ),
                                      parameter_values_json='[]'

      actual_logical_resource_ids = ApiGatewayMethodAuthorizationTypeRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[ApiGatewayMethod1 ApiGatewayMethod2 ApiGatewayMethod3]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context "AWS::ApiGateway::Method has AuthorizationType set to any of the valid values with Default value param refs. " do
    it 'Returns an empty list.' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/api_gateway/api_gateway_method_authorization_type_valid_values_with_param_refs.yaml',
                                          ),
                                      parameter_values_json='[]'

      actual_logical_resource_ids = ApiGatewayMethodAuthorizationTypeRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context "AWS::ApiGateway::Method AuthorizationType is Nil. " do
    it 'Returns offending logical resource ids.' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/api_gateway/api_gateway_method_authorization_type_nil_value.yaml'
                                      )

      actual_logical_resource_ids = ApiGatewayMethodAuthorizationTypeRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[ApiGatewayMethod1 ApiGatewayMethod2]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context "AWS::ApiGateway::Method AuthorizationType is NONE but has HttpMethod: OPTIONS. " do
    it 'An empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/api_gateway/api_gateway_method_with_httpmethod_options.yaml'
                                      ),
                                      parameter_values_json='[]'

      actual_logical_resource_ids = ApiGatewayMethodAuthorizationTypeRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end