require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/EFSFileSystemEncryptedRule'

describe EFSFileSystemEncryptedRule do
  context 'Filesystem without encryption' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'json/efs/filesystem_with_no_encryption.json'
      )

      actual_logical_resource_ids = EFSFileSystemEncryptedRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[filesystem]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Filesystem with encryption' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template('json/efs/filesystem_with_encryption.json')

      actual_logical_resource_ids = EFSFileSystemEncryptedRule.new.audit_impl cfn_model
      expected_logical_resource_ids = []

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Filesystem with encryption set to false string' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/efs/filesystem_with_encryption_false.json')

      actual_logical_resource_ids = EFSFileSystemEncryptedRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[filesystem]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'Filesystem with encryption set to false boolean' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/efs/filesystem_with_encryption_false_boolean.json')

      actual_logical_resource_ids = EFSFileSystemEncryptedRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[filesystem]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
