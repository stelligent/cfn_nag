require 'spec_helper'
require 'cfn-nag/custom_rules/EC2NetworkAclEntryDuplicateRule'
require 'cfn-model'

describe EC2NetworkAclEntryDuplicateRule do
  context 'EC2 Network ACLs entries have duplicate rule numbers for both egress and ingress' do
    it 'returns the offending logical resource ids' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_duplicate_rule_numbers.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryDuplicateRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[myNetworkAclEntry myNetworkAclEntry2 myNetworkAclEntry3 myNetworkAclEntry4]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACLs do not have duplicate rule numbers' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_no_duplicate_rule_numbers.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryDuplicateRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACL entries duplicate rule numbers between egress and ingress' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_egress_ingress_dupe_rule_numbers.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryDuplicateRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACL entries duplicate some rule numbers within and between egress, ingress, and acls' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_some_duplicate_rule_numbers.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryDuplicateRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[myNetworkAclEntry2 myNetworkAclEntry3]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
