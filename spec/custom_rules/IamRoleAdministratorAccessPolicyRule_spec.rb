require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/IamRoleAdministratorAccessPolicyRule'

describe IamRoleAdministratorAccessPolicyRule do
  context 'role with attached AWS Managed AdministratorAccess policy' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/iam_role/iam_role_with_administratoraccess_policy.json')

      actual_logical_resource_ids = IamRoleAdministratorAccessPolicyRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[RoleWithAdministratorAccessPolicy]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
