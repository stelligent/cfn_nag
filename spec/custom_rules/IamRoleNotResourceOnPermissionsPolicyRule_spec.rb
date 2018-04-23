require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/IamRoleNotResourceOnPermissionsPolicyRule'

describe IamRoleNotResourceOnPermissionsPolicyRule do
  context 'policy with a NotResource on the permissions policy' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/iam_role/iam_role_not_resource.json')

      actual_logical_resource_ids = IamRoleNotResourceOnPermissionsPolicyRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[RootRole RootRole2]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
