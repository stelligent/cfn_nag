require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/RDSInstanceMasterUsernameRule'

describe RDSInstanceMasterUsernameRule, :rule do
  context 'RDS instance with NoEcho username' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/rds_instance/rds_instance_no_echo_username.json')

      actual_logical_resource_ids = RDSInstanceMasterUsernameRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w()

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'RDS instance with literal username' do
    it 'says all is well' do
      cfn_model = CfnParser.new.parse read_test_template('json/rds_instance/rds_instance_literal_username.json')

      actual_logical_resource_ids = RDSInstanceMasterUsernameRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w(BadDb)

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'RDS instance with NoEcho parameter that has default' do
    it 'says all is well' do
      cfn_model = CfnParser.new.parse read_test_template('json/rds_instance/rds_instance_no_echo_with_default_username.json')

      actual_logical_resource_ids = RDSInstanceMasterUsernameRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w(BadDb2)

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
