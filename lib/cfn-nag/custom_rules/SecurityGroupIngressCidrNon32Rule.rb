# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'
require 'cfn-nag/ip_addr'

class SecurityGroupIngressCidrNon32Rule < BaseRule
  include IpAddr

  def rule_text
    'Security Groups found with ingress cidr that is not /32'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W9'
  end

  ##
  # This will behave slightly different than the legacy jq based rule which was
  # targeted against inline ingress only
  def audit_impl(cfn_model)
    violating_security_groups = cfn_model.security_groups.select do |security_group|
      violating_ingresses = security_group.ingresses.select do |ingress|
        ip4_cidr_range?(ingress) || ip6_cidr_range?(ingress)
      end

      !violating_ingresses.empty?
    end

    violating_ingresses = cfn_model.standalone_ingress.select do |standalone_ingress|
      ip4_cidr_range?(standalone_ingress) || ip6_cidr_range?(standalone_ingress)
    end

    violating_security_groups.map(&:logical_resource_id) + violating_ingresses.map(&:logical_resource_id)
  end
end
