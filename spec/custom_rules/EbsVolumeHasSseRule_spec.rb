require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/EbsVolumeHasSseRule'

describe EbsVolumeHasSseRule do
  context 'EBS volumes without encryption' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'json/ec2_volume/two_ebs_volumes_with_no_encryption.json'
      )

      actual_logical_resource_ids = EbsVolumeHasSseRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[NewVolume1 NewVolume2]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'EBS volume with encryption' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template('json/ec2_volume/ebs_volume_with_encryption.json')

      actual_logical_resource_ids = EbsVolumeHasSseRule.new.audit_impl cfn_model
      expected_logical_resource_ids = []

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'EBS volume with encryption false - string' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/ec2_volume/ebs_volume_without_encryption_string.json')

      actual_logical_resource_ids = EbsVolumeHasSseRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[NewVolumeA]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'EBS volume with encryption false - string - external' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse(
        read_test_template(
          'json/ec2_volume/ebs_volume_without_encryption_string_externalized.json'
        ), IO.read('spec/test_templates/json/ec2_volume/ebs_volume_parameters.json')
      )

      actual_logical_resource_ids = EbsVolumeHasSseRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[NewVolumeA]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
