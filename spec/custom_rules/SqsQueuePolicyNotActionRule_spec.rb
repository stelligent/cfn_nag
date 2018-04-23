require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/SqsQueuePolicyNotActionRule'

describe SqsQueuePolicyNotActionRule do
  context 'sqs queue policy with NotAction' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/sqs_queue_policy/sqs_policy_with_not_action.json')

      actual_logical_resource_ids = SqsQueuePolicyNotActionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[QueuePolicyWithNotAction QueuePolicyWithNotAction2]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
