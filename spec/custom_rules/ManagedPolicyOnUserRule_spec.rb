require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/ManagedPolicyOnUserRule'

describe ManagedPolicyOnUserRule do
  context 'managed policy assoicated with a User' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/iam_managed_policy/iam_managed_policy_on_user.json')

      actual_logical_resource_ids = ManagedPolicyOnUserRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[DirectManagedPolicy]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
