require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/SqsQueuePolicyNotPrincipalRule'

describe SqsQueuePolicyNotPrincipalRule do
  context 'sqs queue policy with NotPrincipal' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/sqs_queue_policy/sqs_policy_with_not_principal.json')

      actual_logical_resource_ids = SqsQueuePolicyNotPrincipalRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[QueuePolicyWithNotPrincipal]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
