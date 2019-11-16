require 'spec_helper'
require 'password_rule_spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/OpsWorksStackRdsDbInstancePasswordRule'

describe OpsWorksStackRdsDbInstancePasswordRule do
  context 'OpsWorks Stack RDS DBInstance resource with parameter DbPassword with NoEcho but default value' do
    it 'Returns the logical resource ID of the offending AWS::OpsWorks::Stack resource' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ops_works/ops_works_stack_rds_db_instance_password_parameter_noecho_with_default.yaml'
      )

      actual_logical_resource_ids =
        OpsWorksStackRdsDbInstancePasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[MyOpsWorksStack MyOpsWorksStack2]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'OpsWorks Stack RDS DBInstance resource with parameter DbPassword with default value' do
    it 'Returns the logical resource ID of the offending AWS::OpsWorks::Stack resource' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ops_works/ops_works_stack_rds_db_instance_password_parameter_default.yaml'
      )

      actual_logical_resource_ids =
        OpsWorksStackRdsDbInstancePasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[MyOpsWorksStack MyOpsWorksStack3]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'OpsWorks Stack RDS DBInstance resource with parameter DbPassword with NoEcho' do
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

  context 'OpsWorks Stack RDS DBInstance resource has a DbPassword in plain text' do
    it 'Returns the logical resource ID of the offending AWS::OpsWorks::Stack resource' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ops_works/ops_works_stack_rds_db_instance_password_plain_text.yaml'
      )

      actual_logical_resource_ids =
        OpsWorksStackRdsDbInstancePasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[MyOpsWorksStack MyOpsWorksStack2]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'OpsWorks Stack RDS DBInstance has DbPassword from Secrets Manager' do
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

  context 'OpsWorks Stack RDS DBInstance has DbPassword from Secure String in Systems Manager' do
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

  context 'OpsWorks Stack RDS DBInstance has DbPassword from Not Secure String in Systems Manager' do
    it 'returns offending logical resource id for offending AWS::OpsWorks::Stack resource' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ops_works/ops_works_stack_rds_db_instance_password_ssm_not_secure.yaml'
      )
      actual_logical_resource_ids =
        OpsWorksStackRdsDbInstancePasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[MyOpsWorksStack MyOpsWorksStack2]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'OpsWorks Stack RDS DBInstance exists but with DbPassword key not defined' do
    it 'returns offending logical resource id for offending AWS::OpsWorks::Stack resource' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ops_works/ops_works_stack_rds_db_instance_password_key_not_defined.yaml'
      )
      actual_logical_resource_ids =
        OpsWorksStackRdsDbInstancePasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[MyOpsWorksStack2]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'OpsWorks Stack RDS DBInstance exists but  DbPassword key value is nil. ' do
    it 'returns offending logical resource id for offending AWS::OpsWorks::Stack resource' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ops_works/ops_works_stack_rds_db_instance_password_key_value_nil.yaml'
      )
      actual_logical_resource_ids =
        OpsWorksStackRdsDbInstancePasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[MyOpsWorksStack2]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'OpsWorks Stack RDS DBInstance property does NOT exist (as it is not a required property).' do
    it 'returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ops_works/ops_works_stack_rds_db_instance_property_not_defined.yaml'
      )
      actual_logical_resource_ids =
        OpsWorksStackRdsDbInstancePasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
