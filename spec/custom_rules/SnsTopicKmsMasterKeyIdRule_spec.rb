require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/SnsTopicKmsMasterKeyIdRule'

describe SnsTopicKmsMasterKeyIdRule do
  context 'sns topic with no KmsMasterKeyId property defined.' do
    it 'returns offending logical resource ids' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/sns/sns_topic_kms_master_key_id_not_defined.yaml')

      actual_logical_resource_ids = SnsTopicKmsMasterKeyIdRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[SnsTopic1]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'sns topic with KmsMasterKeyId property defined.' do
    it 'an empty list' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/sns/sns_topic_kms_master_key_id_defined.yaml')

      actual_logical_resource_ids = SnsTopicKmsMasterKeyIdRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'sns topic with KmsMasterKeyId property defined and referencing parameter.' do
    it 'an empty list' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/sns/sns_topic_kms_master_key_id_defined_with_parameter.yaml')

      actual_logical_resource_ids = SnsTopicKmsMasterKeyIdRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end