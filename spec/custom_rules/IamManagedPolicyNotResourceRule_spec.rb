require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/IamManagedPolicyNotResourceRule'

describe IamManagedPolicyNotResourceRule do
  context 'managed policy with a NotResource' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/iam_managed_policy/iam_managed_policy_with_not_resource.json')

      actual_logical_resource_ids = IamManagedPolicyNotResourceRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[CreateTestDBPolicy2]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
