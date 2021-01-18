require 'spec_helper'
require 'password_rule_spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/KendraIndexServerSideEncryptionConfigurationKmsKeyIdRule'

describe KendraIndexServerSideEncryptionConfigurationKmsKeyIdRule do
  context 'Kendra Index without ServerSideConfiguration set' do
    it 'Returns the logical resource ID of the offending KendraIndex resource' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/kendra_index/kendra_index_server_side_encryption_configuration_not_set.yaml'
      )

      actual_logical_resource_ids =
        KendraIndexServerSideEncryptionConfigurationKmsKeyIdRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[KendraIndex]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  
  context 'Kendra Index ServerSideConfiguration without KmsKeyId set' do
    it 'Returns the logical resource ID of the offending KendraIndex resource' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/kendra_index/kendra_index_server_side_encryption_configuration_kms_key_id_not_set.yaml'
      )

      actual_logical_resource_ids =
        KendraIndexServerSideEncryptionConfigurationKmsKeyIdRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[KendraIndex]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Kendra Index ServerSideConfiguration with KmsKeyId set' do
    it 'Returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/kendra_index/kendra_index_server_side_encryption_configuration_kms_key_id_set.yaml'
      )

      actual_logical_resource_ids =
        KendraIndexServerSideEncryptionConfigurationKmsKeyIdRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
