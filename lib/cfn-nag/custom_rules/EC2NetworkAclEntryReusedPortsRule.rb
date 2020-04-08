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
      egress_entries = egress?(nacl.network_acl_entries)
      ingress_entries = ingress?(nacl.network_acl_entries)
      violating_nacl_entries += reused_ports?(egress_entries) && reused_ports?(ingress_entries) &&
                                ports_overlap?(egress_entries) && ports_overlap?(ingress_entries)
    end

    violating_nacl_entries.uniq.map(&:logical_resource_id)
  end

  private

  def reused_ports?(nacl_entries)
    ports = []
    reused = []
    nacl_entries.each do |nacl_entry|
      if ports.include?(nacl_entry.portRange)
        reused << nacl_entry
      end
      ports << nacl_entry.portRange
    end
    reused
  end

  def ports_overlap?(nacl_entries)
    port_min = -1
    port_max = -1
    overlaps = []
    nacl_entries.each do |nacl_entry|
      nacl_from = nacl_entry.portRange['From'].to_i
      nacl_to = nacl_entry.portRange['To'].to_i
      if port_min == -1 || port_max == -1
        port_min = nacl_from
        port_max = nacl_to
        next
      end

      if nacl_from.between?(port_min, port_max) ||
         nacl_to.between?(port_min, port_max)
        overlaps << nacl_entry
      end
      port_min = port_min_reset(port_min, nacl_from)
      port_max = port_max_reset(port_max, nacl_to)
    end
    overlaps
  end

  def port_min_reset(port_min, nacl_from)
    nacl_from < port_min ? nacl_from : port_min
  end

  def port_max_reset(port_max, nacl_to)
    nacl_to > port_max ? nacl_to : port_max
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
