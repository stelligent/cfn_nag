require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/missing_property_base_rule'

describe MissingPropertyBaseRule do
  describe '#audit' do
    before(:all) do
      @base_rule = MissingPropertyBaseRule.new
      @base_rule.instance_eval do
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
          'AWS::Redshift::Cluster'
        end

        def property_name
          :masterUserPassword
        end
      end
    end

    before(:all) do
      @failing_violation = Violation.new(id: 'F3334',
                                         type: Violation::FAILING_VIOLATION,
                                         message: 'This is an epic fail!',
                                         logical_resource_ids: %w[RedshiftCluster])
    end

    it 'raises an error when properties are not set' do
      expect do
        MissingPropertyBaseRule.new.audit_impl nil
      end.to raise_error 'must implement in subclass'
    end

    it 'returns violation when property is not set' do
      base_rule = @base_rule

      expect(base_rule).to \
        receive(:property_name).and_return(:masterUserPassword)
      expect(base_rule).to \
        receive(:resource_type).and_return('AWS::Redshift::Cluster')

      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/redshift_cluster/' \
        'redshift_cluster_master_user_password_not_set.yaml'
      )

      expected_violation = @failing_violation

      expect(base_rule.audit(cfn_model)).to eq expected_violation
    end

    it 'returns no violation when property is set' do
      base_rule = @base_rule

      expect(base_rule).to \
        receive(:property_name).and_return(:masterUserPassword)
      expect(base_rule).to \
        receive(:resource_type).and_return('AWS::Redshift::Cluster')

      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/redshift_cluster/' \
        'redshift_cluster_master_user_password_parameter_with_noecho.yaml'
      )

      expect(base_rule.audit(cfn_model)).to be nil
    end
  end
end
