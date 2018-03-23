require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/CloudFormationAuthenticationRule'

describe CloudFormationAuthenticationRule do
  context 'authentication metadata is specified' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/ec2_instance/cfn_authentication.json')

      actual_logical_resource_ids = CloudFormationAuthenticationRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[EC2I4LBA1]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
