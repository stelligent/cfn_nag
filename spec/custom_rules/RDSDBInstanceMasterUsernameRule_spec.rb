require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/RDSDBInstanceMasterUsernameRule'

describe RDSDBInstanceMasterUsernameRule, :rule do
  context 'RDS DB Instance without master user name set' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/rds_dbinstance/rds_dbinstance_no_master_user_name.yml'
      )

      actual_logical_resource_ids =
        RDSDBInstanceMasterUsernameRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'RDS DB Instance with parameter master user name with NoEcho' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/rds_dbinstance/' \
        'rds_dbinstance_master_user_name_parameter_noecho.yml'
      )

      actual_logical_resource_ids =
        RDSDBInstanceMasterUsernameRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'RDS DB Instance with parameter master user name in plaintext' do
    it 'returns offending logical resource id for offending DBInstance' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/rds_dbinstance/' \
        'rds_dbinstance_master_user_name_parameter_plaintext.yml'
      )

      actual_logical_resource_ids =
        RDSDBInstanceMasterUsernameRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[RDSDBInstance]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'RDS DB Instance with literal master user name in plaintext' do
    it 'returns offending logical resource id for offending DBInstance' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/rds_dbinstance/rds_dbinstance_master_user_name_plaintext.yml'
      )

      actual_logical_resource_ids =
        RDSDBInstanceMasterUsernameRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[RDSDBInstance]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'RDS DB Instance with parameter master user name with NoEcho ' \
    'that has Default value' do
    it 'returns offending logical resource id for offending DBInstance' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/rds_dbinstance/' \
        'rds_dbinstance_master_user_name_parameter_noecho_with_default.yml'
      )
      actual_logical_resource_ids =
        RDSDBInstanceMasterUsernameRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[RDSDBInstance]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'RDS DB Instance master user name from Secrets Manager' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/rds_dbinstance/' \
        'rds_dbinstance_master_user_name_secrets_manager.yml'
      )
      actual_logical_resource_ids =
        RDSDBInstanceMasterUsernameRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'RDS DB Instance master user name from Secure Systems Manager' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/rds_dbinstance/rds_dbinstance_master_user_name_ssm-secure.yml'
      )
      actual_logical_resource_ids =
        RDSDBInstanceMasterUsernameRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'RDS DB Instance master user name from Systems Manager' do
    it 'returns offending logical resource id for offending DBInstance' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/rds_dbinstance/rds_dbinstance_master_user_name_ssm.yml'
      )
      actual_logical_resource_ids =
        RDSDBInstanceMasterUsernameRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[RDSDBInstance]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end

