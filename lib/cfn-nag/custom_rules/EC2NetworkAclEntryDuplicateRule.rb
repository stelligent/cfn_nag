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
    violating_nacl_egress_entries = []
    violating_nacl_ingress_entries = []
    cfn_model.resources_by_type('AWS::EC2::NetworkAcl').select do |nacl|
      egress_entries = egress?(nacl.network_acl_entries)
      ingress_entries = ingress?(nacl.network_acl_entries)
      violating_nacl_egress_entries += duplicate_rule_numbers?(egress_entries)
      violating_nacl_ingress_entries += duplicate_rule_numbers?(ingress_entries)
    end

    violating_nacl_egress_entries.map(&:logical_resource_id) + violating_nacl_ingress_entries.map(&:logical_resource_id)
  end

  private

  def duplicate_rule_numbers?(nacl_entries)
    rule_numbers = []
    duplicates = []
    nacl_entries.select do |nacl_entry|
      if rule_numbers.include?(nacl_entry.ruleNumber)
        duplicates << nacl_entry
      end
      rule_numbers << nacl_entry.ruleNumber
    end
    duplicates
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
