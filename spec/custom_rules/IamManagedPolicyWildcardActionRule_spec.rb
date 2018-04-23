require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/IamManagedPolicyWildcardActionRule'

describe IamManagedPolicyWildcardActionRule do
  context 'managed policy with a wildcard Action' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/iam_managed_policy/iam_managed_policy_with_wildcard_action.json')

      actual_logical_resource_ids = IamManagedPolicyWildcardActionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[CreateTestDBPolicy3]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
