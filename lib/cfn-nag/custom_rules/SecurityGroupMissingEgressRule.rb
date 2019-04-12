# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class SecurityGroupMissingEgressRule < BaseRule
  def rule_text
    'Missing egress rule means all traffic is allowed outbound.  Make this explicit if it is desired configuration'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F1000'
  end

  def audit_impl(cfn_model)
    logical_resource_ids = []
    cfn_model.security_groups.each do |security_group|
      logical_resource_ids << security_group.logical_resource_id if security_group.egresses.empty?
    end

    logical_resource_ids
  end
end
