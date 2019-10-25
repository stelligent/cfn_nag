require 'spec_helper'
require 'password_rule_spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/OpsWorksStackRdsDbInstancePasswordRule'

describe OpsWorksStackRdsDbInstancePasswordRule do
  context 'OpsWorks Stack RDS DBInstance resource with parameter password with NoEcho but default value' do
    it 'Returns the logical resource ID of the offending AWS::OpsWorks::Stack resouce' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ops_works/ops_works_stack_rds_db_instance_password_parameter_noecho_with_default.yaml'
      )

      actual_logical_resource_ids =
        OpsWorksStackRdsDbInstancePasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[MyOpsWorksStack]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'OpsWorks Stack RDS DBInstance resource with parameter password with default value' do
    it 'Returns the logical resource ID of the offending AWS::OpsWorks::Stack resouce' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ops_works/ops_works_stack_rds_db_instance_password_parameter_default.yaml'
      )

      actual_logical_resource_ids =
        OpsWorksStackRdsDbInstancePasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[MyOpsWorksStack]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'OpsWorks Stack RDS DBInstance resource with parameter password with NoEcho' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ops_works/ops_works_stack_rds_db_instance_password_parameter_noecho.yaml'
      )

      actual_logical_resource_ids =
        OpsWorksStackRdsDbInstancePasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'OpsWorks Stack RDS DBInstance resource has a password in plaint text' do
    it 'Returns the logical resource ID of the offending AWS::OpsWorks::Stack resouce' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ops_works/ops_works_stack_rds_db_instance_password_plain_text.yaml'
      )

      actual_logical_resource_ids =
        OpsWorksStackRdsDbInstancePasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[MyOpsWorksStack]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'OpsWorks Stack RDS DBInstance has password from Secrets Manager' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ops_works/ops_works_stack_rds_db_instance_password_secrets_manager.yaml'
      )
      actual_logical_resource_ids =
        OpsWorksStackRdsDbInstancePasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'OpsWorks Stack RDS DBInstance has password from Secure String in Systems Manager' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ops_works/ops_works_stack_rds_db_instance_password_ssm_secure.yaml'
      )
      actual_logical_resource_ids =
        OpsWorksStackRdsDbInstancePasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'OpsWorks Stack RDS DBInstance has password from Not Secure String in Systems Manager' do
    it 'returns offending logical resource id for offending AWS::OpsWorks::Stack resouce' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ops_works/ops_works_stack_rds_db_instance_password_ssm_not_secure.yaml'
      )
      actual_logical_resource_ids =
        OpsWorksStackRdsDbInstancePasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[MyOpsWorksStack]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
