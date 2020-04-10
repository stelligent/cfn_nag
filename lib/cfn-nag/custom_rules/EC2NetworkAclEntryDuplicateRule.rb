# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/truthy'
require_relative 'base'

class EC2NetworkAclEntryDuplicateRule < BaseRule
  def rule_text
    'A NetworkACL\'s rule numbers cannot be repeated unless one is egress and one is ingress.'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F79'
  end

  def audit_impl(cfn_model)
    violating_nacl_entries = []
    cfn_model.resources_by_type('AWS::EC2::NetworkAcl').each do |nacl|
      violating_nacl_entries += violating_nacl_entries(nacl)
    end

    violating_nacl_entries.map(&:logical_resource_id)
  end

  private

  def duplicate_rule_numbers(nacl_entries)
    nacl_entries.group_by(&:ruleNumber).select { |_, entries| entries.size > 1 }.map { |_, entries| entries }.flatten
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
    duplicate_rule_numbers(egress(nacl.network_acl_entries)) +
      duplicate_rule_numbers(ingress(nacl.network_acl_entries))
  end
end
