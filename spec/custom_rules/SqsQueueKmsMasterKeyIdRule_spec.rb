require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/SqsQueueKmsMasterKeyIdRule'

describe SqsQueueKmsMasterKeyIdRule do
  context 'sqs queue with no KmsMasterKeyId property defined.' do
    it 'returns offending logical resource ids' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/sqs/sqs_queue_kms_master_key_id_not_defined.yaml')

      actual_logical_resource_ids = SqsQueueKmsMasterKeyIdRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[SqsQueue2]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'sqs queue with KmsMasterKeyId property defined.' do
    it 'an empty list' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/sqs/sqs_queue_kms_master_key_id_defined.yaml')

      actual_logical_resource_ids = SqsQueueKmsMasterKeyIdRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'sqs queue with KmsMasterKeyId property defined and referencing parameter.' do
    it 'an empty list' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/sqs/sqs_queue_kms_master_key_id_defined_with_parameter.yaml')

      actual_logical_resource_ids = SqsQueueKmsMasterKeyIdRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end