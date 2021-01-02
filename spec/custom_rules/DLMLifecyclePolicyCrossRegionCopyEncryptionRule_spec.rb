require 'spec_helper'
require 'password_rule_spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/DLMLifecyclePolicyCrossRegionCopyEncryptionRule'

describe DLMLifecyclePolicyCrossRegionCopyEncryptionRule do
  context 'DLM LifecyclePolicy PolicyDetails Actions not used' do
    it 'Returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/dlm_lifecyclepolicy/dlm_lifecyclepolicy_actions_not_set.yaml'
      )

      actual_logical_resource_ids =
        DLMLifecyclePolicyCrossRegionCopyEncryptionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'DLM LifecyclePolicy PolicyDetails Actions CrossRegionCopy EncryptionConfiguration Encrypted set to False' do
    it 'Returns the logical resource ID of the offending DLM LifecyclePolicy resource' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/dlm_lifecyclepolicy/dlm_lifecyclepolicy_cross_region_copy_encrypted_set_to_false.yaml'
      )

      actual_logical_resource_ids =
        DLMLifecyclePolicyCrossRegionCopyEncryptionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[DLMLifeCyclePolicy]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'DLM LifecyclePolicy PolicyDetails Actions CrossRegionCopy EncryptionConfiguration Encrypted set to True' do
    it 'Returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/dlm_lifecyclepolicy/dlm_lifecyclepolicy_cross_region_copy_encrypted_set_to_true.yaml'
      )

      actual_logical_resource_ids =
        DLMLifecyclePolicyCrossRegionCopyEncryptionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
