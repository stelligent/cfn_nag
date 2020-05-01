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
    violating_nacl_entries = []
    cfn_model.resources_by_type('AWS::EC2::NetworkAcl').each do |nacl|
      violating_nacl_entries += violating_nacl_entries(nacl)
    end
    violating_nacl_entries.map(&:logical_resource_id)
  end

  private

  def overlapping_port_entries(nacl_entries)
    unique_pairs(nacl_entries).select do |nacl_entry_pair|
      tcp_or_udp_protocol?(nacl_entry_pair[0], nacl_entry_pair[1]) && overlap?(nacl_entry_pair[0], nacl_entry_pair[1])
    end
  end

  def tcp_or_udp_protocol?(entry1, entry2)
    %w[6 17].include?(entry1.protocol.to_s) && %w[6 17].include?(entry2.protocol.to_s)
  end

  def unique_pairs(arr)
    pairs_without_dupes = arr.product(arr).select { |pair| pair[0] != pair[1] }
    pairs_without_dupes.reduce(Set.new) { |set_of_sets, pair| set_of_sets << Set.new(pair) }.to_a.map(&:to_a)
  end

  def overlap?(entry1, entry2)
    roverlap?(entry1, entry2) || loverlap?(entry1, entry2)
  end

  def roverlap?(entry1, entry2)
    entry1.portRange['From'].between?(entry2.portRange['From'], entry2.portRange['To']) ||
      entry1.portRange['To'].between?(entry2.portRange['From'], entry2.portRange['To'])
  end

  def loverlap?(entry1, entry2)
    entry2.portRange['From'].between?(entry1.portRange['From'], entry1.portRange['To']) ||
      entry2.portRange['To'].between?(entry1.portRange['From'], entry1.portRange['To'])
  end

  def egress_entries(nacl_entries)
    nacl_entries.select do |nacl_entry|
      truthy?(nacl_entry.egress)
    end
  end

  def ingress_entries(nacl_entries)
    nacl_entries.select do |nacl_entry|
      not_truthy?(nacl_entry.egress)
    end
  end

  def violating_nacl_entries(nacl)
    overlapping_port_entries(egress_entries(nacl.network_acl_entries)).flatten.uniq &&
      overlapping_port_entries(ingress_entries(nacl.network_acl_entries)).flatten.uniq
  end
end
