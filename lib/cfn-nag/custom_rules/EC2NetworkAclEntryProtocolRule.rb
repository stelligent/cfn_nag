# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class EC2NetworkAclEntryProtocolRule < BaseRule
  def rule_text
    'EC2 NetworkACL Entry Protocol must be either 6 (for TCP), 17 (for UDP), 1 (for ICMP), or 58' \
    '(for ICMPv6, which must include an IPv6 CIDR block, ICMP type, and code).'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F79'
  end

  def audit_impl(cfn_model)
    violating_network_acl_entries = cfn_model.resources_by_type('AWS::EC2::NetworkAclEntry')
                                             .select do |network_acl_entry|
      violating_network_acl_entries?(network_acl_entry)
    end

    violating_network_acl_entries.map(&:logical_resource_id)
  end

  private

  # https://docs.aws.amazon.com/AWSEC2/latest/APIReference/API_CreateNetworkAclEntry.html#API_CreateNetworkAclEntry_RequestParameters
  # A value of "-1" means all protocols. If you specify "-1" or a protocol
  # number other than "6" (TCP), "17" (UDP), or "1" (ICMP), traffic on all ports
  # is allowed, regardless of any ports or ICMP types or codes that you specify.
  # If you specify protocol "58" (ICMPv6) and specify an IPv4 CIDR block,
  # traffic for all ICMP types and codes allowed, regardless of any that you
  # specify. If you specify protocol "58" (ICMPv6) and specify an IPv6 CIDR
  # block, you must specify an ICMP type and code.

  def tcp_udp_icmp_protocol?(network_acl_entry)
    %w[1 6 17].include?(network_acl_entry.protocol)
  end

  def icmpv6_protocol?(network_acl_entry)
    network_acl_entry.protocol == '58' && !network_acl_entry.ipv6CidrBlock.nil? &&
      !network_acl_entry.icmp.nil? && !network_acl_entry.icmp['Code'].nil? &&
      !network_acl_entry.icmp['Type'].nil?
  end

  def violating_network_acl_entries?(network_acl_entry)
    if tcp_udp_icmp_protocol?(network_acl_entry) ||
       icmpv6_protocol?(network_acl_entry)
      false
    else
      true
    end
  end
end
