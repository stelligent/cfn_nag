require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/IamRoleElevatedManagedPolicyRule'

describe IamRoleElevatedManagedPolicyRule do
  context 'role with attached AWS Managed PowerUserAccess policy' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/iam_role/iam_role_with_poweruseraccess_policy.json')

      actual_logical_resource_ids = IamRoleElevatedManagedPolicyRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[RoleWithPowerUserAccessPolicy]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'role with attached AWS Managed IAMFullAccess policy' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/iam_role/iam_role_with_iamfullaccess_policy.json')

      actual_logical_resource_ids = IamRoleElevatedManagedPolicyRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[RoleWithIAMFullAccessPolicy]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
