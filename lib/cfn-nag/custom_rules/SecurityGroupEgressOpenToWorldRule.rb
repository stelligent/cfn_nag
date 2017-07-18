require 'cfn-nag/violation'
require_relative 'base'
require 'cfn-nag/ip_addr'

class SecurityGroupEgressOpenToWorldRule < BaseRule
  include IpAddr

  def rule_text
    'Security Groups found with cidr open to world on egress'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W5'
  end

  ##
  # This will behave slightly different than the legacy jq based rule which was targeted against inline ingress only
  def audit_impl(cfn_model)
    logical_resource_ids = []
    cfn_model.security_groups.each do |security_group|
      violating_egresses = security_group.securityGroupEgress.select do |egress|
        ip4_open?(egress) || ip6_open?(egress)
      end

      unless violating_egresses.empty?
        logical_resource_ids << security_group.logical_resource_id
      end
    end

    violating_egresses = cfn_model.standalone_egress.select do |standalone_egress|
      ip4_open?(standalone_egress) || ip6_open?(standalone_egress)
    end

    logical_resource_ids + violating_egresses.map { |egress| egress.logical_resource_id}
  end
end
