# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class SecurityGroupEgressAllProtocolsRule < BaseRule
  def rule_text
    'Security Groups egress with an IpProtocol of -1 found'
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
        if egress.ipProtocol.is_a?(Integer) || egress.ipProtocol.is_a?(String)
          egress.ipProtocol.to_i == -1
        else
          false
        end
      end

      !violating_egresses.empty?
    end

    violating_egresses = cfn_model.standalone_egress.select do |standalone_egress|
      if standalone_egress.ipProtocol.is_a?(Integer) || standalone_egress.ipProtocol.is_a?(String)
        standalone_egress.ipProtocol.to_i == -1
      else
        false
      end
    end

    violating_security_groups.map(&:logical_resource_id) + violating_egresses.map(&:logical_resource_id)
  end
end
