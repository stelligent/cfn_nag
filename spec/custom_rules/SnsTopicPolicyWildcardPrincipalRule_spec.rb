require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/SnsTopicPolicyWildcardPrincipalRule'

describe SnsTopicPolicyWildcardPrincipalRule do
  context 'sns topic policy with wildcard Principal' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/sns_topic_policy/sns_topic_with_wildcard_principal.json')

      actual_logical_resource_ids = SnsTopicPolicyWildcardPrincipalRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[mysnspolicy0 mysnspolicy1 mysnspolicy2 mysnspolicy3]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
