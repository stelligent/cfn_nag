# frozen_string_literal: true

require 'cfn-nag/violation'
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
    violating_egress_entries = []
    violating_ingress_entries = []
    cfn_model.resources_by_type('AWS::EC2::NetworkAcl')
             .select do |nacl|
      violating_egress_entries = deny_does_not_cover_all_cidrs?(cfn_model, nacl.network_acl_egress_entries) ||
                                 reused_ports?(cfn_model, nacl.network_acl_egress_entries)
      violating_ingress_entries = deny_does_not_cover_all_cidrs?(cfn_model, nacl.network_acl_ingress_entries) ||
                                  reused_ports?(cfn_model, nacl.network_acl_ingress_entries)
    end

    violating_egress_entries.map(&:logical_resource_id) + violating_ingress_entries.map(&:logical_resource_id)
  end

  private

  def deny_does_not_cover_all_cidrs?(cfn_model, nacl_entries)
    nacl_entry_resources = []
    nacl_entries.select do |nacl_entry|
      nacl_entry_resources << cfn_model.resource_by_id(nacl_entry)
    end
    nacl_entry_resources.select do |nacl_entry_resource|
      nacl_entry_resource.ruleAction == 'deny' && ((!nacl_entry_resource.cidrBlock.nil? &&
        nacl_entry_resource.cidrBlock != '0.0.0.0/0') ||
        (!nacl_entry_resource.ipv6CidrBlock.nil? && nacl_entry_resource.ipv6CidrBlock != '::/0'))
    end
  end
end
