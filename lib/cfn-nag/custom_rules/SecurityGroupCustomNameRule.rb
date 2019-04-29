# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'
require 'pry'

class SecurityGroupCustomNameRule < BaseRule
  def rule_text
    'Security Groups found with custom name, disallowing updates that ' \
    'require replacement of this resource'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W28'
  end

  def audit_impl(cfn_model)
    violating_security_groups = cfn_model.security_groups.select do |security_group|
      security_group.groupName
    end

    violating_security_groups.map(&:logical_resource_id)
  end
end
