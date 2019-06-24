require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/DMSEndpointPasswordRule'

describe DMSEndpointPasswordRule, :rule do
  context 'DMS Endpoint without password set' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/dms_endpoint/dms_endpoint_no_password.yml'
      )

      actual_logical_resource_ids =
        DMSEndpointPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'DMS Endpoint with parameter password with NoEcho' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/dms_endpoint/dms_endpoint_password_parameter_noecho.yml'
      )

      actual_logical_resource_ids =
        DMSEndpointPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'DMS Endpoint with literal password in plaintext' do
    it 'returns offending logical resource id for offending DMS Endpoint' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/dms_endpoint/dms_endpoint_password_plaintext.yml'
      )

      actual_logical_resource_ids =
        DMSEndpointPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[DMSEndpoint]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'DMS Endpoint with parameter password with NoEcho ' \
    'that has Default value' do
    it 'returns offending logical resource id for offending DMS Endpoint' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/dms_endpoint/' \
        'dms_endpoint_password_parameter_noecho_with_default.yml'
      )
      actual_logical_resource_ids =
        DMSEndpointPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[DMSEndpoint]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'DMS Endpoint password from Secrets Manager' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/dms_endpoint/dms_endpoint_password_secrets_manager.yml'
      )
      actual_logical_resource_ids =
        DMSEndpointPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'DMS Endpoint password from Secure Systems Manager' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/dms_endpoint/dms_endpoint_password_ssm-secure.yml'
      )
      actual_logical_resource_ids =
        DMSEndpointPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'DMS Endpoint password from Systems Manager' do
    it 'returns offending logical resource id for offending DMS Endpoint' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/dms_endpoint/dms_endpoint_password_ssm.yml'
      )
      actual_logical_resource_ids =
        DMSEndpointPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[DMSEndpoint]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
