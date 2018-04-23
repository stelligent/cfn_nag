require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/SqsQueuePolicyWildcardActionRule'

describe SqsQueuePolicyWildcardActionRule do
  context 'sqs queue policy with wildcard Action' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/sqs_queue_policy/sqs_queue_with_wildcards.json')

      actual_logical_resource_ids = SqsQueuePolicyWildcardActionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[mysqspolicy1 mysqspolicy1b mysqspolicy1c mysqspolicy1d]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
