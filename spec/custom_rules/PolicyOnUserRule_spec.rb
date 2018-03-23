require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/PolicyOnUserRule'

describe PolicyOnUserRule do
  context 'policy associated with a User' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/iam_policy/iam_policy_on_user.json')

      actual_logical_resource_ids = PolicyOnUserRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[DirectPolicy]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
