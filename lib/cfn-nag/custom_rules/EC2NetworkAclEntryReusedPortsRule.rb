# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/truthy'
require_relative 'base'

class EC2NetworkAclEntryReusedPortsRule < BaseRule
  def rule_text
    'NetworkACL Entries are reusing or overlapping ports which may create ineffective rules.'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W72'
  end

  def audit_impl(cfn_model)
    violating_nacl_entries = []
    cfn_model.resources_by_type('AWS::EC2::NetworkAcl').each do |nacl|
      violating_nacl_entries += violating_nacl_entries(nacl)
    end

    violating_nacl_entries.uniq.map(&:logical_resource_id)
  end

  private

  def reused_ports(nacl_entries)
    nacl_entries.group_by(&:portRange).select { |_, entries| entries.size > 1 }.map { |_, entries| entries }.flatten
  end

  def overlapping_port_entries(nacl_entries)
    ports = nil
    nacl_entries.select do |nacl_entry|
      nacl_entry_range = nacl_entry.portRange['From'].to_i..nacl_entry.portRange['To'].to_i
      current_port_range = ports
      ports = update_overlapping_port_range(nacl_entry_range, current_port_range)
      if nacl_entry_ports_overlap?(nacl_entries, nacl_entry, nacl_entry_range, current_port_range)
        nacl_entry
      end
    end
  end

  def update_overlapping_port_range(nacl_entry_range, ports)
    if ports.nil?
      nacl_entry_range
    else
      port_min = nacl_entry_range.min < ports.min ? nacl_entry_range.min : ports.min
      port_max = nacl_entry_range.max > ports.max ? nacl_entry_range.max : ports.max
      port_min..port_max
    end
  end

  def nacl_entry_ports_overlap?(nacl_entries, nacl_entry, nacl_entry_range, ports)
    if nacl_entry != nacl_entries.detect.first
      nacl_entry_range.min.between?(ports.min, ports.max) || nacl_entry_range.max.between?(ports.min, ports.max)
    end
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
    reused_ports(egress(nacl.network_acl_entries)) +
      overlapping_port_entries(egress(nacl.network_acl_entries)) +
      reused_ports(ingress(nacl.network_acl_entries)) +
      overlapping_port_entries(ingress(nacl.network_acl_entries))
  end
end
