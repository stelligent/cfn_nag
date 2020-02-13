require 'spec_helper'
require 'cfn-nag/custom_rules/EC2NetworkAclMissingVpcIdRule'
require 'cfn-model'

describe EC2NetworkAclMissingVpcIdRule do
  context 'EC2 Network ACL a missing VPC ID' do
    it 'returns the offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkacl/ec2_networkacl_missing_vpc_id.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclMissingVpcIdRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[EC2NACL]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACL is not missing a VPC ID' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkacl/ec2_networkacl_with_vpc_id.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclMissingVpcIdRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
