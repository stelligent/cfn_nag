require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/IamPolicyNotActionRule'

describe IamPolicyNotActionRule do
  context 'policy with a NotAction' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/iam_policy/iam_policy_with_not_action.json')

      actual_logical_resource_ids = IamPolicyNotActionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[NotActionPolicy]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
