require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/ECRRepositoryScanOnPushRule'

describe ECRRepositoryScanOnPushRule do
  context 'ecr registry without scan on push enabled' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ecrregistry/registries_with_no_scanonpush_enabled.yaml'
      )

      actual_logical_resource_ids = ECRRepositoryScanOnPushRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[MyRepositoryWithScanDisabled MyRepositoryWithNoConfigDefault]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'ecr registry with scan on push enabled' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ecrregistry/registries_with_scanonpush_enabled.yaml'
      )

      actual_logical_resource_ids = ECRRepositoryScanOnPushRule.new.audit_impl cfn_model
      expected_logical_resource_ids = []

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
