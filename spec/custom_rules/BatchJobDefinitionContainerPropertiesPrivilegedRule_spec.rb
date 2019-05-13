require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/BatchJobDefinitionContainerPropertiesPrivilegedRule'

describe BatchJobDefinitionContainerPropertiesPrivilegedRule do
  context 'when Batch::JobDefinition ContainerProperties does not have Privileged specified' do
    it 'returns offending logical resource id for offending JobDefinition' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/batch/batch_jobdefinition_no_container_properties_priveleged_specified.yml'
      )

      actual_logical_resource_ids =
        BatchJobDefinitionContainerPropertiesPrivilegedRule.new.audit_impl cfn_model

      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'when Batch::JobDefinition ContainerProperties has Privileged==true boolean' do
    it 'returns offending logical resource id for offending JobDefinition' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/batch/batch_jobdefinition_container_properties_priveleged_true_boolean.yml'
      )

      actual_logical_resource_ids =
        BatchJobDefinitionContainerPropertiesPrivilegedRule.new.audit_impl cfn_model

      expected_logical_resource_ids = %w[BatchJobDefinition]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'when Batch::JobDefinition ContainerProperties has Privileged==True Boolean' do
    it 'returns offending logical resource id for offending JobDefinition' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/batch/batch_jobdefinition_container_properties_priveleged_true_boolean_case.yml'
      )

      actual_logical_resource_ids =
        BatchJobDefinitionContainerPropertiesPrivilegedRule.new.audit_impl cfn_model

      expected_logical_resource_ids = %w[BatchJobDefinition]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'when Batch::JobDefinition ContainerProperties has Privileged==true string' do
    it 'returns offending logical resource id for offending JobDefinition' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/batch/batch_jobdefinition_container_properties_priveleged_true_string.yml'
      )

      actual_logical_resource_ids =
        BatchJobDefinitionContainerPropertiesPrivilegedRule.new.audit_impl cfn_model

      expected_logical_resource_ids = %w[BatchJobDefinition]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'when Batch::JobDefinition ContainerProperties has Privileged==True String' do
    it 'returns offending logical resource id for offending JobDefinition' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/batch/batch_jobdefinition_container_properties_priveleged_true_string_case.yml'
      )

      actual_logical_resource_ids =
        BatchJobDefinitionContainerPropertiesPrivilegedRule.new.audit_impl cfn_model

      expected_logical_resource_ids = %w[BatchJobDefinition]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'when Batch::JobDefinition ContainerProperties has Privileged==false boolean' do
    it 'returns offending logical resource id for offending JobDefinition' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/batch/batch_jobdefinition_container_properties_priveleged_false_boolean.yml'
      )

      actual_logical_resource_ids =
        BatchJobDefinitionContainerPropertiesPrivilegedRule.new.audit_impl cfn_model

      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'when Batch::JobDefinition ContainerProperties has Privileged==False Boolean' do
    it 'returns offending logical resource id for offending JobDefinition' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/batch/batch_jobdefinition_container_properties_priveleged_false_boolean_case.yml'
      )

      actual_logical_resource_ids =
        BatchJobDefinitionContainerPropertiesPrivilegedRule.new.audit_impl cfn_model

      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'when Batch::JobDefinition ContainerProperties has Privileged==false string' do
    it 'returns offending logical resource id for offending JobDefinition' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/batch/batch_jobdefinition_container_properties_priveleged_false_string.yml'
      )

      actual_logical_resource_ids =
        BatchJobDefinitionContainerPropertiesPrivilegedRule.new.audit_impl cfn_model

      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'when Batch::JobDefinition ContainerProperties has Privileged==false string' do
    it 'returns offending logical resource id for offending JobDefinition' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/batch/batch_jobdefinition_container_properties_priveleged_false_string_case.yml'
      )

      actual_logical_resource_ids =
        BatchJobDefinitionContainerPropertiesPrivilegedRule.new.audit_impl cfn_model

      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
