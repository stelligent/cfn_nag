require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/CognitoIdentityPoolAllowUnauthenticatedIdentitiesRule'

describe CognitoIdentityPoolAllowUnauthenticatedIdentitiesRule do
  context "AWS::Cognito::IdentityPool AllowUnauthenticatedIdentities set to true. " do
    it 'Returns offending logical resource ids' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/cognito/cognito_identity_pool_allowunauthenticatedidentities_true.yaml'
                                      )

      actual_logical_resource_ids = CognitoIdentityPoolAllowUnauthenticatedIdentitiesRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[CognitoIdentityPool1 CognitoIdentityPool2]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context "AWS::Cognito::IdentityPool AllowUnauthenticatedIdentities set to false. " do
    it 'Returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/cognito/cognito_identity_pool_allowunauthenticatedidentities_false.yaml'
                                      )

      actual_logical_resource_ids = CognitoIdentityPoolAllowUnauthenticatedIdentitiesRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context "AWS::Cognito::IdentityPool AllowUnauthenticatedIdentities with Default value parameter references. " do
    it 'Returns offending logical resource ids' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/cognito/cognito_identity_pool_allowunauthenticatedidentities_default_value_param_refs.yaml'
                                      ),
                                      parameter_values_json='[]'

      actual_logical_resource_ids = CognitoIdentityPoolAllowUnauthenticatedIdentitiesRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[CognitoIdentityPool1 CognitoIdentityPool2]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context "AWS::Cognito::IdentityPool AllowUnauthenticatedIdentities with parameter references but no Default values. " do
    it 'Returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/cognito/cognito_identity_pool_allowunauthenticatedidentities_param_refs_no_default_values.yaml'
                                      )

      actual_logical_resource_ids = CognitoIdentityPoolAllowUnauthenticatedIdentitiesRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end