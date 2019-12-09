require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/password_base_rule'

describe PasswordBaseRule do
  describe '#audit' do
    before(:all) do
      @base_rule = PasswordBaseRule.new
      @base_rule.instance_eval do
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
          'AWS::Redshift::Cluster'
        end

        def password_property
          :masterUserPassword
        end
      end
    end

    before(:all) do
      @failing_violation = Violation.new(id: 'F3333',
                                         type: Violation::FAILING_VIOLATION,
                                         message: 'This is an epic fail!',
                                         logical_resource_ids: %w[RedshiftCluster])
    end

    it 'raises an error when properties are not set' do
      expect do
        PasswordBaseRule.new.audit_impl nil
      end.to raise_error 'must implement in subclass'
    end

    it 'returns no violation when password is not set' do
      base_rule = @base_rule

      expect(base_rule).to \
        receive(:password_property).and_return(:masterUserPassword)
      expect(base_rule).to \
        receive(:resource_type).and_return('AWS::Redshift::Cluster')

      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/redshift_cluster/' \
        'redshift_cluster_master_user_password_not_set.yaml'
      )

      expect(base_rule.audit(cfn_model)).to be nil
    end

    it 'returns no violation when password is parameter with noecho' do
      base_rule = @base_rule

      expect(base_rule).to \
        receive(:password_property).and_return(:masterUserPassword,
                                               :masterUserPassword)
      expect(base_rule).to \
        receive(:resource_type).and_return('AWS::Redshift::Cluster')

      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/redshift_cluster/' \
        'redshift_cluster_master_user_password_parameter_with_noecho.yaml'
      )

      expect(base_rule.audit(cfn_model)).to be nil
    end

    it 'returns violation when password is literal in plaintext' do
      base_rule = @base_rule

      expect(base_rule).to \
        receive(:password_property).and_return(:masterUserPassword,
                                               :masterUserPassword)
      expect(base_rule).to \
        receive(:resource_type).and_return('AWS::Redshift::Cluster')

      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/redshift_cluster/' \
        'redshift_cluster_master_user_password_as_a_literal_in_plaintext.yaml'
      )

      expected_violation = @failing_violation

      expect(base_rule.audit(cfn_model)).to eq expected_violation
    end

    it 'returns violation when password is parameter with noecho and ' \
      'has a default value present' do
      base_rule = @base_rule

      expect(base_rule).to \
        receive(:password_property).and_return(:masterUserPassword,
                                               :masterUserPassword)
      expect(base_rule).to \
        receive(:resource_type).and_return('AWS::Redshift::Cluster')

      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/redshift_cluster/' \
        'redshift_cluster_master_user_password_parameter_with_noecho_and_default_value.yaml'
      )

      expected_violation = @failing_violation

      expect(base_rule.audit(cfn_model)).to eq expected_violation
    end

    it 'returns no violation when password is from secrets manager' do
      base_rule = @base_rule

      expect(base_rule).to \
        receive(:password_property).and_return(:masterUserPassword,
                                               :masterUserPassword)
      expect(base_rule).to \
        receive(:resource_type).and_return('AWS::Redshift::Cluster')

      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/redshift_cluster/' \
        'redshift_cluster_master_user_password_from_secrets_manager.yaml'
      )

      expect(base_rule.audit(cfn_model)).to be nil
    end

    it 'returns no violation when password is from secure systems manager' do
      base_rule = @base_rule

      expect(base_rule).to \
        receive(:password_property).and_return(:masterUserPassword,
                                               :masterUserPassword)
      expect(base_rule).to \
        receive(:resource_type).and_return('AWS::Redshift::Cluster')

      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/redshift_cluster/' \
        'redshift_cluster_master_user_password_from_secure_systems_manager.yaml'
      )

      expect(base_rule.audit(cfn_model)).to be nil
    end

    it 'returns violation when password is systems manager' do
      base_rule = @base_rule

      expect(base_rule).to \
        receive(:password_property).and_return(:masterUserPassword,
                                               :masterUserPassword)
      expect(base_rule).to \
        receive(:resource_type).and_return('AWS::Redshift::Cluster')

      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/redshift_cluster/' \
        'redshift_cluster_master_user_password_from_systems_manager.yaml'
      )

      expected_violation = @failing_violation

      expect(base_rule.audit(cfn_model)).to eq expected_violation
    end

    it 'returns no violation when password_property is not defined in resource' do
      base_rule = PasswordBaseRule.new
      base_rule.instance_eval do
        def rule_id
          'F3334'
        end

        def rule_type
          Violation::FAILING_VIOLATION
        end

        def rule_text
          'This is an epic fail!'
        end

        def resource_type
          'AWS::IAM::User'
        end

        def password_property
          :loginProfile
        end

        def sub_property_name
          'Password'
        end
      end

      expect(base_rule).to \
        receive(:sub_property_name).and_return('Password')
      expect(base_rule).to \
        receive(:password_property).and_return(:loginProfile)
      expect(base_rule).to \
        receive(:resource_type).and_return('AWS::IAM::User')

      cfn_model = CfnParser.new.parse read_test_template(
        'json/iam_user/iam_user_with_no_group.json'
      )

      expect(base_rule.audit(cfn_model)).to be nil
    end
  end
end
