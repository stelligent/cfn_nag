require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/KinesisFirehoseDeliveryStreamEncryptionRule'

describe KinesisFirehoseDeliveryStreamEncryptionRule do
  context 'Kinesis Firehose DeliveryStream with encryption defined.' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/kinesisfirehose_deliverystream/kinesisfirehose_deliverystream_encryption_defined.yaml')

      actual_logical_resource_ids = KinesisFirehoseDeliveryStreamEncryptionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Kinesis Firehose DeliveryStream with encryption not defined.' do
    it 'returns offending logical resource ids' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/kinesisfirehose_deliverystream/kinesisfirehose_deliverystream_encryption_not_defined.yaml')

      actual_logical_resource_ids = KinesisFirehoseDeliveryStreamEncryptionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[DeliveryStream1]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Kinesis Firehose DeliveryStream with encryption defined and referencing parameter.' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/kinesisfirehose_deliverystream/kinesisfirehose_deliverystream_encryption_defined_with_parameter.yaml')

      actual_logical_resource_ids = KinesisFirehoseDeliveryStreamEncryptionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Kinesis Firehose DeliveryStream with encryption defined without KeyType.' do
    it 'returns offending logical resource ids' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/kinesisfirehose_deliverystream/kinesisfirehose_deliverystream_encryption_defined_without_key_type.yaml')

      actual_logical_resource_ids = KinesisFirehoseDeliveryStreamEncryptionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[DeliveryStream1]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
