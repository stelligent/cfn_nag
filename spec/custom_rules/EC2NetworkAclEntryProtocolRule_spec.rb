require 'spec_helper'
require 'cfn-nag/custom_rules/EC2NetworkAclEntryProtocolRule'
require 'cfn-model'

describe EC2NetworkAclEntryProtocolRule do
  context 'EC2 Network ACL Entry uses a Protocol of 6 for TCP with Rule Action Allow' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_protocol_tcp.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryProtocolRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACL Entry uses a Protocol of 17 for UDP with Rule Action Allow' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_protocol_udp.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryProtocolRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACL Entry uses a Protocol of 1 for ICMP with Rule Action Allow' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_protocol_icmp.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryProtocolRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACL Entry uses a Protocol of 58 for ICMPv6 with Rule Action Allow' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_protocol_icmpv6.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryProtocolRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACL Entry uses a Protocol of 58 for ICMPv6 with an ICMPv4 CidrBlock with Rule Action Allow' do
    it 'returns the offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_protocol_icmpv6_with_icmpv4_cidrblock.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryProtocolRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[myNetworkAclEntry]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACL Entry uses a Protocol of 58 for ICMPv6 without ICMP parameters with Rule Action Allow' do
    it 'returns the offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_protocol_icmpv6_missing_icmp.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryProtocolRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[myNetworkAclEntry]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACL Entry uses a Protocol of -1 for all protocols with Rule Action Allow' do
    it 'returns the offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_all_protocols.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryProtocolRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[myNetworkAclEntry]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACL Entry uses a Protocol of 6 for TCP with Rule Action Deny' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_protocol_tcp_deny.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryProtocolRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACL Entry uses a Protocol of -1 for all protocols with Rule Action Deny' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/ec2_networkaclentry/ec2_networkaclentry_all_protocols_deny.yml'
      )

      actual_logical_resource_ids = EC2NetworkAclEntryProtocolRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
  context 'EC2 Network ACL Entry uses a Protocol of 6 for TCP but as a number' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
                                        'yaml/ec2_networkaclentry/int_protocol.yml'
                                      )

      actual_logical_resource_ids = EC2NetworkAclEntryProtocolRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
