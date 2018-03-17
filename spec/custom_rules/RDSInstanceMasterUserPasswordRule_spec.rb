require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/RDSInstanceMasterUserPasswordRule'

describe RDSInstanceMasterUserPasswordRule, :rule do
  context 'RDS instance with NoEcho password' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/rds_instance/rds_instance_no_echo_password.json')

      actual_logical_resource_ids = RDSInstanceMasterUserPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w()

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'RDS instance with literal password' do
    it 'says all is well' do
      cfn_model = CfnParser.new.parse read_test_template('json/rds_instance/rds_instance_literal_password.json')

      actual_logical_resource_ids = RDSInstanceMasterUserPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w(BadDb)

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'RDS instance with plaintext parameter' do
    it 'says all is well' do
      cfn_model = CfnParser.new.parse read_test_template('json/rds_instance/rds_instance_plain_parameter.json')

      actual_logical_resource_ids = RDSInstanceMasterUserPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w(BadDb3)

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'RDS instance with NoEcho parameter that has default' do
    it 'says all is well' do
      cfn_model = CfnParser.new.parse read_test_template('json/rds_instance/rds_instance_no_echo_with_default_password.json')

      actual_logical_resource_ids = RDSInstanceMasterUserPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w(BadDb2)

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  # context 'RDS instance with NoEcho password + dangerous substitution' do
  #   it 'returns offending logical resource id' do
  #     cfn_model = CfnParser.new.parse read_test_template('json/rds_instance/rds_instance_without_publicly_accessible.json')
  #
  #     actual_logical_resource_ids = RDSInstancePubliclyAccessibleRule.new.audit_impl cfn_model
  #     expected_logical_resource_ids = %w(AmbiguousDb)
  #
  #     expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
  #   end
  # end
end
