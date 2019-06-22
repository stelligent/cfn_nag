require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/DirectoryServiceSimpleADPasswordRule'

describe DirectoryServiceSimpleADPasswordRule, :rule do

  context 'Good SimpleAD with parameter, no echo true, and no default' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'json/simple_ad/good_no_echo_no_default.json'
      )

      actual_logical_resource_ids =
        DirectoryServiceSimpleADPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Bad SimpleAD with default password' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'json/simple_ad/with_default_password.json'
      )

      actual_logical_resource_ids =
        DirectoryServiceSimpleADPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[SimpleAD]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Bad SimpleAD with noecho parameter but specifies password' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'json/simple_ad/with_default_password_and_no_echo.json'
      )

      actual_logical_resource_ids =
        DirectoryServiceSimpleADPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[SimpleAD]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Bad SimpleAD with parameter noecho set to false' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'json/simple_ad/with_no_echo_false.json'
      )

      actual_logical_resource_ids =
        DirectoryServiceSimpleADPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[SimpleAD]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Bad SimpleAD without password parameter' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'json/simple_ad/without_parameter.json'
      )

      actual_logical_resource_ids =
        DirectoryServiceSimpleADPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[SimpleAD]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Good SimpleAD with password from Secrets Manager' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'json/simple_ad/simple_ad_password_secrets_manager.json'
      )
      actual_logical_resource_ids =
        DirectoryServiceSimpleADPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Good SimpleAD with password from Secure Systems Manager' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'json/simple_ad/simple_ad_password_ssm-secure.json'
      )
      actual_logical_resource_ids =
        DirectoryServiceSimpleADPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Good SimpleAD with password from Systems Manager' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'json/simple_ad/simple_ad_password_ssm.json'
      )
      actual_logical_resource_ids =
        DirectoryServiceSimpleADPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[SimpleAD]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
