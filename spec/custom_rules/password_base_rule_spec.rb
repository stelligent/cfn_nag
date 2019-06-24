require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/password_base_rule'

describe PasswordBaseRule do
  describe '#audit' do
    it 'raises an error when properties are not set' do
      expect do
        PasswordBaseRule.new.audit_impl nil
      end.to raise_error 'must implement in subclass'
    end

    it 'returns no violation when password is not set' do
      base_rule = PasswordBaseRule.new
      base_rule.instance_eval do
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

      expect(base_rule).to \
        receive(:password_property).and_return(:masterUserPassword)
      expect(base_rule).to \
        receive(:resource_type).and_return('AWS::Redshift::Cluster')

      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/redshift_cluster/redshift_cluster_no_master_user_password.yml'
      )

      expect(base_rule.audit(cfn_model)).to be nil
    end

    it 'returns no violation when password is parameter with noecho' do
      base_rule = PasswordBaseRule.new
      base_rule.instance_eval do
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

      expect(base_rule).to \
        receive(:password_property).and_return(:masterUserPassword,
                                               :masterUserPassword,
                                               :masterUserPassword)
      expect(base_rule).to \
        receive(:resource_type).and_return('AWS::Redshift::Cluster')

      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/redshift_cluster/' \
        'redshift_cluster_master_user_password_parameter_noecho.yml'
      )

      expect(base_rule.audit(cfn_model)).to be nil
    end

    it 'returns violation when password is literal in plaintext' do
      base_rule = PasswordBaseRule.new
      base_rule.instance_eval do
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

      expect(base_rule).to \
        receive(:password_property).and_return(:masterUserPassword,
                                               :masterUserPassword,
                                               :masterUserPassword)
      expect(base_rule).to \
        receive(:resource_type).and_return('AWS::Redshift::Cluster')

      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/redshift_cluster/' \
        'redshift_cluster_master_user_password_plaintext.yml'
      )

      expected_violation = Violation.new(id: 'F3333',
                                         type: Violation::FAILING_VIOLATION,
                                         message: 'This is an epic fail!',
                                         logical_resource_ids: %w[RedshiftCluster])

      expect(base_rule.audit(cfn_model)).to eq expected_violation
    end

    it 'returns violation when password is parameter with noecho and ' \
      'has a default value present' do
      base_rule = PasswordBaseRule.new
      base_rule.instance_eval do
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

      expect(base_rule).to \
        receive(:password_property).and_return(:masterUserPassword,
                                               :masterUserPassword)
      expect(base_rule).to \
        receive(:resource_type).and_return('AWS::Redshift::Cluster')

      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/redshift_cluster/' \
        'redshift_cluster_master_user_password_parameter_noecho_with_default.yml'
      )

      expected_violation = Violation.new(id: 'F3333',
                                         type: Violation::FAILING_VIOLATION,
                                         message: 'This is an epic fail!',
                                         logical_resource_ids: %w[RedshiftCluster])

      expect(base_rule.audit(cfn_model)).to eq expected_violation
    end

    it 'returns no violation when password is from secrets manager' do
      base_rule = PasswordBaseRule.new
      base_rule.instance_eval do
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

      expect(base_rule).to \
        receive(:password_property).and_return(:masterUserPassword,
                                               :masterUserPassword,
                                               :masterUserPassword)
      expect(base_rule).to \
        receive(:resource_type).and_return('AWS::Redshift::Cluster')

      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/redshift_cluster/' \
        'redshift_cluster_master_user_password_secrets_manager.yml'
      )

      expect(base_rule.audit(cfn_model)).to be nil
    end

    it 'returns no violation when password is from secure systems manager' do
      base_rule = PasswordBaseRule.new
      base_rule.instance_eval do
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

      expect(base_rule).to \
        receive(:password_property).and_return(:masterUserPassword,
                                               :masterUserPassword,
                                               :masterUserPassword)
      expect(base_rule).to \
        receive(:resource_type).and_return('AWS::Redshift::Cluster')

      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/redshift_cluster/' \
        'redshift_cluster_master_user_password_ssm-secure.yml'
      )

      expect(base_rule.audit(cfn_model)).to be nil
    end

    it 'returns violation when password is systems manager' do
      base_rule = PasswordBaseRule.new
      base_rule.instance_eval do
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

      expect(base_rule).to \
        receive(:password_property).and_return(:masterUserPassword,
                                               :masterUserPassword,
                                               :masterUserPassword)
      expect(base_rule).to \
        receive(:resource_type).and_return('AWS::Redshift::Cluster')

      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/redshift_cluster/redshift_cluster_master_user_password_ssm.yml'
      )

      expected_violation = Violation.new(id: 'F3333',
                                         type: Violation::FAILING_VIOLATION,
                                         message: 'This is an epic fail!',
                                         logical_resource_ids: %w[RedshiftCluster])

      expect(base_rule.audit(cfn_model)).to eq expected_violation
    end
  end
end
