require 'spec_helper'
require 'cfn-nag/custom_rules/EC2NetworkAclEntryIneffectiveDenyRule'
require 'cfn-model'

describe EC2NetworkAclEntryIneffectiveDenyRule do
  context 'EC2 Network ACL Entry uses a partial ipv4 CIDR range for a Deny rule' do
    it 'returns the offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_deny_partial_ipv4_cidr_range.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryIneffectiveDenyRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[myNetworkAclEntry]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACL Entry uses a full ipv4 CIDR range for a Deny rule' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_deny_full_ipv4_cidr_range.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryIneffectiveDenyRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACL Entry uses a partial ipv6 CIDR range for a Deny rule' do
    it 'returns the offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_deny_partial_ipv6_cidr_range.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryIneffectiveDenyRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[myNetworkAclEntry]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACL Entry uses a full ipv6 CIDR range for a Deny rule' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_deny_full_ipv6_cidr_range.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryIneffectiveDenyRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
