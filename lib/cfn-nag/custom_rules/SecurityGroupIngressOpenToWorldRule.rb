# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'
require 'cfn-nag/ip_addr'

class SecurityGroupIngressOpenToWorldRule < BaseRule
  include IpAddr

  def rule_text
    'Security Groups found with cidr open to world on ingress.  This should ' \
    'never be true on instance.  Permissible on ELB'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W2'
  end

  ##
  # This will behave slightly different than the legacy jq based rule
  # which was targeted against inline ingress only
  def audit_impl(cfn_model)
    logical_resource_ids = []
    cfn_model.security_groups.each do |security_group|
      violating_ingresses = security_group.ingresses.select do |ingress|
        ip4_open?(ingress) || ip6_open?(ingress)
      end

      next if violating_ingresses.empty?
      logical_resource_ids << security_group.logical_resource_id
    end

    ingress_rules = cfn_model.standalone_ingress
    violating_ingresses = ingress_rules.select do |standalone_ingress|
      ip4_open?(standalone_ingress) || ip6_open?(standalone_ingress)
    end

    logical_resource_ids + violating_ingresses.map(&:logical_resource_id)
  end
end
