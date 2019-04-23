require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/CodeBuildEncryptionKeyRule'

describe CodeBuildEncryptionKeyRule do
  context 'CodeBuild Project without a specified encryption key' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'json/codebuild/without_encryption_key.json'
      )

      actual_logical_resource_ids = CodeBuildEncryptionKeyRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[Project]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'CodeBuild Project with a specified encryption key' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'json/codebuild/with_encryption_key.json'
      )

      actual_logical_resource_ids = CodeBuildEncryptionKeyRule.new.audit_impl cfn_model
      expected_logical_resource_ids = []

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
