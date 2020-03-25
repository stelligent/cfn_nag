# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class EC2NetworkAclEntryReusedPortsRule < BaseRule
  def rule_text
    'NetworkACL Entries are reusing ports which may create ineffective rules.'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W68'
  end

  def audit_impl(cfn_model)
    violating_egress_entries = []
    violating_ingress_entries = []
    cfn_model.resources_by_type('AWS::EC2::NetworkAcl')
             .select do |nacl|
      violating_egress_entries += reused_ports?(cfn_model, nacl.network_acl_egress_entries)
      violating_ingress_entries += reused_ports?(cfn_model, nacl.network_acl_ingress_entries)
    end

    violating_egress_entries.map(&:logical_resource_id) + violating_ingress_entries.map(&:logical_resource_id)
  end

  private

  def reused_ports?(cfn_model, nacl_entries)
    nacl_entry_resources = []
    ports = []
    reused = []
    nacl_entries.select do |nacl_entry|
      nacl_entry_resources << cfn_model.resource_by_id(nacl_entry)
    end
    nacl_entry_resources.select do |nacl_entry_resource|
      if ports.include?(nacl_entry_resource.portRange)
        reused << nacl_entry_resource
      end
      ports << nacl_entry_resource.portRange
    end
    reused
  end
end
