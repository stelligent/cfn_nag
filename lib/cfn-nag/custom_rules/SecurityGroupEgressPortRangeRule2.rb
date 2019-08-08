# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class SecurityGroupEgressPortRangeRule2 < BaseRule
  def rule_text
    'Security Groups with an IpProtocol of -1 found egress with port range'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W40'
  end

  ##
  # This will behave slightly different than the legacy jq based rule which was
  # targeted against inline ingress only
  def audit_impl(cfn_model)
    violating_security_groups = cfn_model.security_groups.select do |security_group|
      violating_egresses = security_group.egresses.select do |egress|
        egress.ipProtocol == -1 && egress.fromPort != egress.toPort
      end

        !violating_egresses.empty?
     end

     # TODO: research standalone egress, is there a CF example?
     violating_egresses = cfn_model.standalone_egress.select do |standalone_egress|
        standalone_egress.ipProtocol == -1 && standalone_egress.fromPort != standalone_egress.toPort
      end

    violating_security_groups.map(&:logical_resource_id) + violating_egresses.map(&:logical_resource_id)
  end
end
