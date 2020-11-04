# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'
require 'cfn-nag/ip_addr'
require 'cfn-nag/util/blank'

class SecurityGroupRuleDescriptionRule < BaseRule
  def rule_text
    'Security group rules without a description obscure their purpose and may '\
    'lead to bad practices in ensuring they only allow traffic from the ports '\
    'and sources/destinations required.'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W36'
  end

  def audit_impl(cfn_model)
    violating_security_groups?(cfn_model) +
      violating_ingress?(cfn_model) +
      violating_egress?(cfn_model)
  end

  private

  def violating_sg_component(sg_component)
    sg_component.select do |item|
      blank?(item['Description'])
    end
  end

  def violating_security_groups?(cfn_model)
    violating_security_groups = cfn_model.security_groups.select do |security_group|
      !violating_sg_component(security_group.securityGroupIngress).empty? ||
        !violating_sg_component(security_group.securityGroupEgress).empty?
    end
    violating_security_groups.map(&:logical_resource_id)
  end

  def violating_ingress?(cfn_model)
    violating_ingress = cfn_model.resources_by_type('AWS::EC2::SecurityGroupIngress').select do |standalone_ingress|
      blank?(standalone_ingress.description)
    end
    violating_ingress.map(&:logical_resource_id)
  end

  def violating_egress?(cfn_model)
    violating_egress = cfn_model.resources_by_type('AWS::EC2::SecurityGroupEgress').select do |standalone_egress|
      blank?(standalone_egress.description)
    end
    violating_egress.map(&:logical_resource_id)
  end
end
