require 'spec_helper'
require 'cfn-nag/custom_rules/EC2NetworkAclEntryProtocolRule'
require 'cfn-model'

describe EC2NetworkAclEntryProtocolRule do
  context 'EC2 Network ACL Entry uses a Protocol of 6 for TCP' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_protocol_tcp.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryProtocolRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACL Entry uses a Protocol of 17 for UDP' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_protocol_udp.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryProtocolRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACL Entry uses a Protocol of 1 for ICMP' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_protocol_icmp.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryProtocolRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACL Entry uses a Protocol of 58 for ICMPv6' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_protocol_icmpv6.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryProtocolRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACL Entry uses a Protocol of 58 for ICMPv6 with an ICMPv4 CidrBlock' do
    it 'returns the offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_protocol_icmpv6_with_icmpv4_cidrblock.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryProtocolRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[myNetworkAclEntry]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACL Entry uses a Protocol of 58 for ICMPv6 without ICMP parameters' do
    it 'returns the offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_protocol_icmpv6_missing_icmp.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryProtocolRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[myNetworkAclEntry]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACL Entry uses a Protocol of -1 for all protocols' do
    it 'returns the offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_all_protocols.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryProtocolRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[myNetworkAclEntry]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
