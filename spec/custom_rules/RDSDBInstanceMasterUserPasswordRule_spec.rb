require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/RDSDBInstanceMasterUserPasswordRule' # TODO: fix naming

describe RDSDBInstanceMasterUserPasswordRule, :rule do
  context 'RDS DB Instance without master user password set' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/rds_dbinstance/rds_dbinstance_no_master_user_password.yml'
      )

      actual_logical_resource_ids =
        RDSDBInstanceMasterUserPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'RDS DB Instance with parameter master user password with NoEcho' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/rds_dbinstance/' \
        'rds_dbinstance_master_user_password_parameter_noecho.yml'
      )

      actual_logical_resource_ids =
        RDSDBInstanceMasterUserPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'RDS DB Instance with parameter master user password in plaintext' do
    it 'returns offending logical resource id for offending DBInstance' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/rds_dbinstance/' \
        'rds_dbinstance_master_user_password_parameter_plaintext.yml'
      )

      actual_logical_resource_ids =
        RDSDBInstanceMasterUserPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[RDSDBInstance]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'RDS DB Instance with literal master user password in plaintext' do
    it 'returns offending logical resource id for offending DBInstance' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/rds_dbinstance/rds_dbinstance_master_user_password_plaintext.yml'
      )

      actual_logical_resource_ids =
        RDSDBInstanceMasterUserPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[RDSDBInstance]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'RDS DB Instance with parameter master user password with NoEcho ' \
    'that has Default value' do
    it 'returns offending logical resource id for offending DBInstance' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/rds_dbinstance/' \
        'rds_dbinstance_master_user_password_parameter_noecho_with_default.yml'
      )
      actual_logical_resource_ids =
        RDSDBInstanceMasterUserPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[RDSDBInstance]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'RDS DB Instance master user password from Secrets Manager' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/rds_dbinstance/' \
        'rds_dbinstance_master_user_password_secrets_manager.yml'
      )
      actual_logical_resource_ids =
        RDSDBInstanceMasterUserPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'RDS DB Instance master user password from Secure Systems Manager' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/rds_dbinstance/' \
        'rds_dbinstance_master_user_password_ssm-secure.yml'
      )
      actual_logical_resource_ids =
        RDSDBInstanceMasterUserPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'RDS DB Instance master user password from Systems Manager' do
    it 'returns offending logical resource id for offending DBInstance' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/rds_dbinstance/rds_dbinstance_master_user_password_ssm.yml'
      )
      actual_logical_resource_ids =
        RDSDBInstanceMasterUserPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[RDSDBInstance]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
