require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/CognitoUserPoolMfaConfigurationOnorOptionalRule'

describe CognitoUserPoolMfaConfigurationOnorOptionalRule do
  context "Cognito UserPool with MfaConfiguration set to 'ON' (Wrapped in quotes, i.e 'ON')." do
    it 'Returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/cognito/cognito_user_pool_mfa_configuration_on_wrapped_in_quotes.yaml'
                                      )

      actual_logical_resource_ids = CognitoUserPoolMfaConfigurationOnorOptionalRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context "Cognito UserPool with MfaConfiguration set to ON/On/on (NOT wrapped in quotes)." do
    it 'Returns offending logical resource ids' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/cognito/cognito_user_pool_mfa_configuration_on_not_wrapped_in_quotes.yaml'
                                      )

      actual_logical_resource_ids = CognitoUserPoolMfaConfigurationOnorOptionalRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  #
  context "Cognito UserPool with MfaConfiguration set to OFF/Off/off or 'OFF'/'Off'/'off' or
  (Wrapped/Not wrapped in quotes and/or NOT fully upper case)." do
    it 'Returns offending logical resource ids' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/cognito/cognito_user_pool_mfa_configuration_off_all_variations.yaml'
                                      )

      actual_logical_resource_ids = CognitoUserPoolMfaConfigurationOnorOptionalRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[CognitoUserPool1
                                         CognitoUserPool2
                                         CognitoUserPool3]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context "Cognito UserPool with MfaConfiguration set to OPTIONAL/'OPTIONAL' (uppercase)." do
    it 'Returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/cognito/cognito_user_pool_mfa_configuration_optional_uppercase.yaml'
                                      )

      actual_logical_resource_ids = CognitoUserPoolMfaConfigurationOnorOptionalRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context "Cognito UserPool with MfaConfiguration set to OFF/Off/off or 'OFF'/'Off'/'off' or
  when referenced by parameter values (Wrapped/Not wrapped in quotes and/or NOT fully upper case)." do
    it 'Returns offending logical resource ids' do
      # by specifying the parameters_values_json, it means apply parameter substitution to the model
      # this is empty, but by triggering the subsitution, it means default values are substituted where defined
      cfn_model = CfnParser.new.parse read_test_template(
                                          'yaml/cognito/cognito_user_pool_mfa_configuration_violations_all_variations_with_param_refs.yaml',
                                      ),
                                      parameter_values_json='[]'

      actual_logical_resource_ids = CognitoUserPoolMfaConfigurationOnorOptionalRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[CognitoUserPool4
                                         CognitoUserPool5
                                         CognitoUserPool6]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
