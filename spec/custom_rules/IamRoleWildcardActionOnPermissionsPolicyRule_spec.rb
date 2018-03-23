require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/IamRoleWildcardActionOnPermissionsPolicyRule'

describe IamRoleWildcardActionOnPermissionsPolicyRule do
  context 'role with a wildcard Action on the perimissions policy' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/iam_role/iam_role_with_wildcard_action.json')

      actual_logical_resource_ids = IamRoleWildcardActionOnPermissionsPolicyRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[WildcardActionRole]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
