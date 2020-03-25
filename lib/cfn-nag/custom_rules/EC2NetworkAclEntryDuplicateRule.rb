# frozen_string_literal: true

require 'cfn-nag/violation'
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
    nacl_violating_egress_entries = []
    nacl_violating_ingress_entries = []
    cfn_model.resources_by_type('AWS::EC2::NetworkAcl').select do |nacl|
      nacl_violating_egress_entries += duplicate_rule_numbers?(cfn_model, nacl.network_acl_egress_entries)
      nacl_violating_ingress_entries += duplicate_rule_numbers?(cfn_model, nacl.network_acl_ingress_entries)
    end

    nacl_violating_egress_entries.map(&:logical_resource_id) + nacl_violating_ingress_entries.map(&:logical_resource_id)
  end

  private

  def duplicate_rule_numbers?(cfn_model, nacl_entries)
    nacl_entry_resources = []
    rule_numbers = []
    duplicates = []
    nacl_entries.select do |nacl_entry|
      nacl_entry_resources << cfn_model.resource_by_id(nacl_entry)
    end
    nacl_entry_resources.select do |nacl_entry_resource|
      if rule_numbers.include?(nacl_entry_resource.ruleNumber)
        duplicates << nacl_entry_resource
      end
      rule_numbers << nacl_entry_resource.ruleNumber
    end
    duplicates
  end
end
