require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/RDSInstanceBackupRetentionPeriodRule'

describe RDSInstanceBackupRetentionPeriodRule do
  context 'RDS instance with backup period set to zero' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/rds_dbinstance/rds_dbinstance_with_backup_retention_period_set_to_zero.yaml'
      )

      actual_logical_resource_ids = RDSInstanceBackupRetentionPeriodRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[RDSDBInstanceWithZeroBackupRetentionPeriod RDSDBInstanceWithStringZeroBackupRetentionPeriod]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'RDS instance without backup period' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/rds_dbinstance/rds_dbinstance_without_backup_retention_period.yaml'
      )

      # The default for the BackupRetentionPeriod property is 1 (https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-rds-database-instance.html#cfn-rds-dbinstance-backupretentionperiod).

      actual_logical_resource_ids = RDSInstanceBackupRetentionPeriodRule.new.audit_impl cfn_model
      expected_logical_resource_ids = []

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'RDS instance with backup period set to greather than zero' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/rds_dbinstance/rds_dbinstance_with_backup_retention_period.yaml'
      )

      actual_logical_resource_ids = RDSInstanceBackupRetentionPeriodRule.new.audit_impl cfn_model
      expected_logical_resource_ids = []

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
