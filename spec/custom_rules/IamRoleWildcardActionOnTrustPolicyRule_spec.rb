require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/IamRoleWildcardActionOnTrustPolicyRule'

describe IamRoleWildcardActionOnTrustPolicyRule do
  context 'role with a wildcard Action on the trust policy' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/iam_role/iam_role_with_wildcard_action_on_trust.json')

      actual_logical_resource_ids = IamRoleWildcardActionOnTrustPolicyRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[WildcardActionRole]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
