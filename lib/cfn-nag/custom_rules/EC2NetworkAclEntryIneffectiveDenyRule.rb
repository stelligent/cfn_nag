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
    'W69'
  end

  def audit_impl(cfn_model)
    violating_nacl_egress_entries = []
    violating_nacl_ingress_entries = []
    cfn_model.resources_by_type('AWS::EC2::NetworkAcl').select do |nacl|
      egress_entries = egress?(nacl.network_acl_entries)
      ingress_entries = ingress?(nacl.network_acl_entries)
      violating_nacl_egress_entries += deny_does_not_cover_all_cidrs?(egress_entries)
      violating_nacl_ingress_entries += deny_does_not_cover_all_cidrs?(ingress_entries)
    end

    violating_nacl_egress_entries.map(&:logical_resource_id) + violating_nacl_ingress_entries.map(&:logical_resource_id)
  end

  private

  def deny_does_not_cover_all_cidrs?(nacl_entries)
    nacl_entries.select do |nacl_entry|
      nacl_entry.ruleAction == 'deny' && ((!nacl_entry.cidrBlock.nil? &&
        nacl_entry.cidrBlock != '0.0.0.0/0') ||
        (!nacl_entry.ipv6CidrBlock.nil? && nacl_entry.ipv6CidrBlock != '::/0'))
    end
  end

  def egress?(nacl_entries)
    nacl_entries.select do |nacl_entry|
      truthy?(nacl_entry.egress)
    end
  end

  def ingress?(nacl_entries)
    nacl_entries.select do |nacl_entry|
      not_truthy?(nacl_entry.egress)
    end
  end
end
