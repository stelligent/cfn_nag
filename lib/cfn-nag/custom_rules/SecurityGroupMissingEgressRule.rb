# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class SecurityGroupMissingEgressRule < BaseRule
  def rule_text
    'Missing egress rule means all traffic is allowed outbound.  Make this ' \
    'explicit if it is desired configuration'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F1000'
  end

  def audit_impl(cfn_model)
    violating_security_groups = cfn_model.security_groups.select do |security_group|
      security_group.egresses.empty?
    end

    violating_security_groups.map(&:logical_resource_id)
  end
end
