require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/RDSInstanceDeletionProtectionRule'

describe RDSInstanceDeletionProtectionRule do
  context 'RDS instance without deletion protection' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/rds_dbinstance/rds_dbinstance_without_deletion_protection.yaml'
      )

      actual_logical_resource_ids = RDSInstanceDeletionProtectionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[RDSDBInstanceWithNoDeletionProtection RDSDBInstanceWithDeletionProtectionDisabled]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'RDS instance with deletion protection enabled' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/rds_dbinstance/rds_dbinstance_with_deletion_protection_enabled.yaml'
      )

      actual_logical_resource_ids = RDSInstanceDeletionProtectionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = []

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
