require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/IamRoleNotActionOnTrustPolicyRule'

describe IamRoleNotActionOnTrustPolicyRule do
  context 'role with a NotAction on the trust policy' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/iam_role/iam_role_not_action_on_trust.json')

      actual_logical_resource_ids = IamRoleNotActionOnTrustPolicyRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[NotActionTrustRole]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
