require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/sub_property_with_list_password_base_rule'

describe SubPropertyWithListPasswordBaseRule do
  describe '#audit' do
    before(:all) do
      @base_rule_with_list = SubPropertyWithListPasswordBaseRule.new
      @base_rule_with_list.instance_eval do
        def rule_id
          'F3333'
        end

        def rule_type
          Violation::FAILING_VIOLATION
        end

        def rule_text
          'This is an epic fail!'
        end

        def resource_type
          'AWS::OpsWorks::Stack'
        end

        def password_property
          :rdsDbInstances
        end

        def sub_property_name
          'DbPassword'
        end
      end
    end

    before(:all) do
      @failing_violation = Violation.new(id: 'F3333',
                                         type: Violation::FAILING_VIOLATION,
                                         message: 'This is an epic fail!',
                                         logical_resource_ids: %w[OpsWorksStack])
    end

    it 'raises an error when properties are not set' do
      expect do
        SubPropertyWithListPasswordBaseRule.new.audit_impl nil
      end.to raise_error 'must implement in subclass'
    end

    it 'returns no violation when password is not set' do
      base_rule_with_list = @base_rule_with_list

      expect(base_rule_with_list).to \
        receive(:sub_property_name).and_return('DbPassword')
      expect(base_rule_with_list).to \
        receive(:password_property).and_return(:rdsDbInstances)
      expect(base_rule_with_list).to \
        receive(:resource_type).and_return('AWS::OpsWorks::Stack')

      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/opsworks_stack/' \
        'opsworks_stack_rds_db_instances_db_password_not_set.yaml'
      )

      expect(base_rule_with_list.audit(cfn_model)).to be nil
    end

    it 'returns no violation when password is parameter with noecho' do
      base_rule_with_list = @base_rule_with_list

      expect(base_rule_with_list).to \
        receive(:sub_property_name).and_return('DbPassword')
      expect(base_rule_with_list).to \
        receive(:password_property).and_return(:rdsDbInstances)
      expect(base_rule_with_list).to \
        receive(:resource_type).and_return('AWS::OpsWorks::Stack')

      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/opsworks_stack/' \
        'opsworks_stack_rds_db_instances_db_password_parameter_with_noecho.yaml'
      )

      expect(base_rule_with_list.audit(cfn_model)).to be nil
    end

    it 'returns violation when password is literal in plaintext' do
      base_rule_with_list = @base_rule_with_list

      expect(base_rule_with_list).to \
        receive(:sub_property_name).and_return('DbPassword')
      expect(base_rule_with_list).to \
        receive(:password_property).and_return(:rdsDbInstances)
      expect(base_rule_with_list).to \
        receive(:resource_type).and_return('AWS::OpsWorks::Stack')

      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/opsworks_stack/' \
        'opsworks_stack_rds_db_instances_db_password_as_a_literal_in_plaintext.yaml'
      )

      expected_violation = @failing_violation

      expect(base_rule_with_list.audit(cfn_model)).to eq expected_violation
    end

    it 'returns violation when password is parameter with noecho and ' \
      'has a default value present' do
      base_rule_with_list = @base_rule_with_list

      expect(base_rule_with_list).to \
        receive(:sub_property_name).and_return('DbPassword')
      expect(base_rule_with_list).to \
        receive(:password_property).and_return(:rdsDbInstances)
      expect(base_rule_with_list).to \
        receive(:resource_type).and_return('AWS::OpsWorks::Stack')

      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/opsworks_stack/' \
        'opsworks_stack_rds_db_instances_db_password_parameter_with_noecho_and_default_value.yaml'
      )

      expected_violation = @failing_violation

      expect(base_rule_with_list.audit(cfn_model)).to eq expected_violation
    end

    it 'returns no violation when password is from secrets manager' do
      base_rule_with_list = @base_rule_with_list

      expect(base_rule_with_list).to \
        receive(:sub_property_name).and_return('DbPassword')
      expect(base_rule_with_list).to \
        receive(:password_property).and_return(:rdsDbInstances)
      expect(base_rule_with_list).to \
        receive(:resource_type).and_return('AWS::OpsWorks::Stack')

      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/opsworks_stack/' \
        'opsworks_stack_rds_db_instances_db_password_from_secrets_manager.yaml'
      )

      expect(base_rule_with_list.audit(cfn_model)).to be nil
    end

    it 'returns no violation when password is from secure systems manager' do
      base_rule_with_list = @base_rule_with_list

      expect(base_rule_with_list).to \
        receive(:sub_property_name).and_return('DbPassword')
      expect(base_rule_with_list).to \
        receive(:password_property).and_return(:rdsDbInstances)
      expect(base_rule_with_list).to \
        receive(:resource_type).and_return('AWS::OpsWorks::Stack')

      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/opsworks_stack/' \
        'opsworks_stack_rds_db_instances_db_password_from_secure_systems_manager.yaml'
      )

      expect(base_rule_with_list.audit(cfn_model)).to be nil
    end

    it 'returns violation when password is systems manager' do
      base_rule_with_list = @base_rule_with_list

      expect(base_rule_with_list).to \
        receive(:sub_property_name).and_return('DbPassword')
      expect(base_rule_with_list).to \
        receive(:password_property).and_return(:rdsDbInstances)
      expect(base_rule_with_list).to \
        receive(:resource_type).and_return('AWS::OpsWorks::Stack')

      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/opsworks_stack/' \
        'opsworks_stack_rds_db_instances_db_password_from_systems_manager.yaml'
      )

      expected_violation = @failing_violation

      expect(base_rule_with_list.audit(cfn_model)).to eq expected_violation
    end
  end
end
