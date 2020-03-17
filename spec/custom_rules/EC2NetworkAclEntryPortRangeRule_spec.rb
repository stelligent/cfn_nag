require 'spec_helper'
require 'cfn-nag/custom_rules/EC2NetworkAclEntryPortRangeRule'
require 'cfn-model'

describe EC2NetworkAclEntryPortRangeRule do
  context 'EC2 Network ACL Entry uses a valid Port Range' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_port_range.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryPortRangeRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACL Entry is missing a Port Range' do
    it 'returns the offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_missing_port_range.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryPortRangeRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[myNetworkAclEntry]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACL Entry is missing the From field of Port Range' do
    it 'returns the offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_missing_port_range_from.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryPortRangeRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[myNetworkAclEntry]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACL Entry is missing the To field of Port Range' do
    it 'returns the offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_missing_port_range_to.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryPortRangeRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[myNetworkAclEntry]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACL Entry allows all ports open by the full range' do
    it 'returns the offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_all_ports_full_range.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryPortRangeRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[myNetworkAclEntry]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
