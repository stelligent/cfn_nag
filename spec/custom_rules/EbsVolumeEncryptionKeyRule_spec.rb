require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/EbsVolumeEncryptionKeyRule'

describe EbsVolumeEncryptionKeyRule do
  context 'EBS volumes without KmsKeyId' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
                                        'json/ec2_volume/two_ebs_volumes_with_no_encryption.json'
                                      )

      actual_logical_resource_ids = EbsVolumeHasSseRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[NewVolume1 NewVolume2]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'EBS volume with KmsKeyId != NoValue' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template('json/ec2_volume/ebs_volume_with_kms_key.json')

      actual_logical_resource_ids = EbsVolumeHasSseRule.new.audit_impl cfn_model
      expected_logical_resource_ids = []

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'EBS volume with KmsKeyID == NoValue' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/ec2_volume/ebs_volume_with_encryption.json')

      actual_logical_resource_ids = EbsVolumeEncryptionKeyRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[NewVolume]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
