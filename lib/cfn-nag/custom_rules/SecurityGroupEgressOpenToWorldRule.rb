# frozen_string_literal: true

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
  # This will behave slightly different than the legacy jq based rule which was
  # targeted against inline ingress only
  def audit_impl(cfn_model)
    violating_security_groups = cfn_model.security_groups.select do |security_group|
      violating_egresses = security_group.egresses.select do |egress|
        violating_egress(egress)
      end

      !violating_egresses.empty?
    end

    violating_egresses = cfn_model.standalone_egress.select do |standalone_egress|
      violating_egress(standalone_egress)
    end

    violating_security_groups.map(&:logical_resource_id) + violating_egresses.map(&:logical_resource_id)
  end

  private

  def violating_egress(egress)
    ip4_open?(egress) || ip6_open?(egress)
  end
end
