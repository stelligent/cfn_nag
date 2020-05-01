# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/truthy'
require_relative 'base'

class EC2NetworkAclEntryIneffectiveDenyRule < BaseRule
  def rule_text
    'NetworkACL Entry Deny rules should affect all CIDR ranges.'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W71'
  end

  def audit_impl(cfn_model)
    violating_nacl_entries = []
    cfn_model.resources_by_type('AWS::EC2::NetworkAcl').each do |nacl|
      violating_nacl_entries += violating_nacl_entries(nacl)
    end

    violating_nacl_entries.map(&:logical_resource_id)
  end

  private

  def deny_does_not_cover_all_cidrs(nacl_entries)
    nacl_entries.select do |nacl_entry|
      nacl_entry.ruleAction == 'deny' && not_all_cidrs_covered?(nacl_entry)
    end
  end

  def not_all_cidrs_covered?(nacl_entry)
    (!nacl_entry.cidrBlock.nil? &&
      nacl_entry.cidrBlock != '0.0.0.0/0') ||
      (!nacl_entry.ipv6CidrBlock.nil? && (nacl_entry.ipv6CidrBlock != '::/0' && nacl_entry.ipv6CidrBlock != ':/0'))
  end

  def egress(nacl_entries)
    nacl_entries.select do |nacl_entry|
      truthy?(nacl_entry.egress)
    end
  end

  def ingress(nacl_entries)
    nacl_entries.select do |nacl_entry|
      not_truthy?(nacl_entry.egress)
    end
  end

  def violating_nacl_entries(nacl)
    deny_does_not_cover_all_cidrs(egress(nacl.network_acl_entries)) +
      deny_does_not_cover_all_cidrs(ingress(nacl.network_acl_entries))
  end
end
