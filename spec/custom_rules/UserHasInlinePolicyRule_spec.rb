require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/UserHasInlinePolicyRule'

describe UserHasInlinePolicyRule do
  context 'iam user with inline poicy' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/iam_user/iam_user_with_inline_policy.json')

      actual_logical_resource_ids = UserHasInlinePolicyRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[userWithInline]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
