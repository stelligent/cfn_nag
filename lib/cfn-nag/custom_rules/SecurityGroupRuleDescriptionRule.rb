# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'
require 'cfn-nag/ip_addr'

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

  def violating_security_groups?(cfn_model)
    violating_security_groups = cfn_model.security_groups.select do |security_group|
      violating_ingres = security_group.ingresses.select do |ingress|
        ingress.description.nil? && ingress.logical_resource_id.nil?
      end
      violating_egress = security_group.egresses.select do |egress|
        egress.description.nil? && egress.logical_resource_id.nil?
      end
      !violating_ingres.empty? || !violating_egress.empty?
    end
    violating_security_groups.map(&:logical_resource_id)
  end

  def violating_ingress?(cfn_model)
    violating_ingress = cfn_model.resources_by_type('AWS::EC2::SecurityGroupIngress').select do |standalone_ingress|
      standalone_ingress&.description.nil?
    end
    violating_ingress.map(&:logical_resource_id)
  end

  def violating_egress?(cfn_model)
    violating_egress = cfn_model.resources_by_type('AWS::EC2::SecurityGroupEgress').select do |standalone_ingress|
      standalone_ingress&.description.nil?
    end
    violating_egress.map(&:logical_resource_id)
  end

  def audit_impl(cfn_model)
    violating_security_groups?(cfn_model) +
      violating_ingress?(cfn_model) +
      violating_egress?(cfn_model)
  end
end
