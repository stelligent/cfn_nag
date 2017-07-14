require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/LambdaPermissionInvokeFunctionActionRule'

describe LambdaPermissionInvokeFunctionActionRule do
  context 'lambda permissions with something besides InvokeFunction on the Action' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/lambda_permission/lambda_with_wildcard_principal_and_non_invoke_function_permission.json')

      actual_logical_resource_ids = LambdaPermissionInvokeFunctionActionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w(lambdaPermission)

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
