require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/KinesisStreamStreamEncryptionRule'

describe KinesisStreamStreamEncryptionRule do
  context 'Kinesis Stream with StreamEncryption property not defined.' do
    it 'returns offending logical resource ids' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/kinesis/kinesis_stream_stream_encryption_not_defined.yaml')

      actual_logical_resource_ids = KinesisStreamStreamEncryptionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[KinesisStream1 KinesisStream3]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Kinesis Stream with StreamEncryption property defined.' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/kinesis/kinesis_stream_stream_encryption_defined.yaml')

      actual_logical_resource_ids = KinesisStreamStreamEncryptionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Kinesis Stream with StreamEncryption property defined and referencing parameter.' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/kinesis/kinesis_stream_stream_encryption_defined_with_parameter.yaml')

      actual_logical_resource_ids = KinesisStreamStreamEncryptionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Kinesis Stream with StreamEncryption property defined and EncryptionType NONE.' do
    it 'returns offending logical resource ids' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/kinesis/kinesis_stream_stream_encryption_defined_encryption_type_none.yaml')

      actual_logical_resource_ids = KinesisStreamStreamEncryptionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[KinesisStream2 KinesisStream3]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Kinesis Stream with StreamEncryption property defined without KeyId.' do
    it 'returns offending logical resource ids' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/kinesis/kinesis_stream_stream_encryption_defined_without_key_id.yaml')

      actual_logical_resource_ids = KinesisStreamStreamEncryptionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[KinesisStream2 KinesisStream3]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Kinesis Stream with StreamEncryption property defined without EncryptionType.' do
    it 'returns offending logical resource ids' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/kinesis/kinesis_stream_stream_encryption_defined_without_encryption_type.yaml')

      actual_logical_resource_ids = KinesisStreamStreamEncryptionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[KinesisStream2 KinesisStream3]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end