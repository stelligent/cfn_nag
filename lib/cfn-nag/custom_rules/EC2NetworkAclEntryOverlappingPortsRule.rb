# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/truthy'
require_relative 'base'

class EC2NetworkAclEntryOverlappingPortsRule < BaseRule
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
    nacl_entries = cfn_model.resources_by_type('AWS::EC2::NetworkAclEntry')

    # Select nacl entries that can be evaluated
    nacl_entries.select! do |nacl_entry|
      tcp_or_udp_protocol?(nacl_entry) && valid_ports?(nacl_entry)
    end

    violating_nacl_entries = []

    # Group entries by nacl id, ip type, and egress/ingress
    grouped_nacl_entries = group_nacl_entries(nacl_entries)

    grouped_nacl_entries.each do |grouping|
      violating_nacl_entries += overlapping_port_entries(grouping)
    end
    violating_nacl_entries.map(&:logical_resource_id)
  end

  private

  def tcp_or_udp_protocol?(entry)
    %w[6 17].include?(entry.protocol.to_s)
  end

  def valid_ports?(entry)
    !entry.portRange.nil? && valid_port_number?(entry.portRange['From']) && valid_port_number?(entry.portRange['To'])
  end

  def valid_port_number?(port)
    port.is_a?(Numeric) || (port.is_a?(String) && port.to_i(10) != 0)
  end

  def group_nacl_entries(nacl_entries)
    grouped_nacl_entries = []

    # Group by NaclID
    nacl_entries.group_by(&:networkAclId).each_value do |entries|
      # Split entries by ip type
      ipv4_entries, ipv6_entries = entries.partition { |nacl_entry| nacl_entry.ipv6CidrBlock.nil? }

      # Split entries by egress/ingress
      egress4, ingress4 = ipv4_entries.partition { |nacl_entry| truthy?(nacl_entry.egress) }
      egress6, ingress6 = ipv6_entries.partition { |nacl_entry| truthy?(nacl_entry.egress) }

      grouped_nacl_entries << egress4
      grouped_nacl_entries << ingress4
      grouped_nacl_entries << egress6
      grouped_nacl_entries << ingress6
    end

    grouped_nacl_entries
  end

  def overlapping_port_entries(nacl_entries)
    unique_pairs(nacl_entries).select do |nacl_entry_pair|
      overlap?(nacl_entry_pair[0], nacl_entry_pair[1])
    end.flatten.uniq
  end

  def unique_pairs(arr)
    pairs_without_dupes = arr.product(arr).select { |pair| pair[0] != pair[1] }
    pairs_without_dupes.reduce(Set.new) { |set_of_sets, pair| set_of_sets << Set.new(pair) }.to_a.map(&:to_a)
  end

  def overlap?(entry1, entry2)
    port_overlap?(entry1.portRange, entry2.portRange) || port_overlap?(entry2.portRange, entry1.portRange)
  end

  def port_overlap?(port_range1, port_range2)
    port_number(port_range1['From']).between?(port_number(port_range2['From']), port_number(port_range2['To'])) ||
      port_number(port_range1['To']).between?(port_number(port_range2['From']), port_number(port_range2['To']))
  end

  def port_number(port)
    port.to_i
  end
end
