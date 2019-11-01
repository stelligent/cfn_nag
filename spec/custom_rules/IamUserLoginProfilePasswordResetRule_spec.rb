require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/IamUserLoginProfilePasswordResetRule'

describe IamUserLoginProfilePasswordResetRule do
  context 'when IAM::User resource LoginProfile property has PasswordResetRequired set to false' do
    it 'returns logical resource ID for the offending IAM User' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/iam_user/iam_user_login_profile_password_reset_false.yaml'
      )

      actual_logical_resource_ids = IamUserLoginProfilePasswordResetRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[MyIamUser]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'when IAM::User resource LoginProfile property has PasswordResetRequired set to true' do
    it 'returns empty array' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/iam_user/iam_user_login_profile_password_reset_true.yaml'
      )

      actual_logical_resource_ids = IamUserLoginProfilePasswordResetRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'when IAM::User resource LoginProfile property does not have PasswordResetRequired key defined' do
    it 'returns logical resource ID for the offending IAM User' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/iam_user/iam_user_login_profile_password_reset_required_key_not_defined.yaml'
      )

      actual_logical_resource_ids = IamUserLoginProfilePasswordResetRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[MyIamUser]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'when IAM::User resource does not have LoginProfile property defined' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/iam_user/iam_user_login_profile_property_not_defined.yaml'
      )

      actual_logical_resource_ids = IamUserLoginProfilePasswordResetRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'when IAM::User resource LoginProfile property PasswordResetRequired key is nil.' do
    it 'returns logical resource ID for the offending IAM User' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/iam_user/iam_user_login_profile_password_reset_required_key_nil.yaml'
      )

      actual_logical_resource_ids = IamUserLoginProfilePasswordResetRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[MyIamUser]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
