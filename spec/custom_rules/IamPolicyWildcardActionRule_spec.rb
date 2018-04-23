require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/IamPolicyWildcardActionRule'

describe IamPolicyWildcardActionRule do
  context 'policy with a wildcard Action' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/iam_policy/iam_policy_with_wildcard_action.json')

      actual_logical_resource_ids = IamPolicyWildcardActionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[WildcardActionPolicy]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
