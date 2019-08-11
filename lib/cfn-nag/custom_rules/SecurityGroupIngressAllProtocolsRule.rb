# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class SecurityGroupIngressAllProtocolsRule < BaseRule
  def rule_text
    'Security Groups ingress with an ipProtocol of -1 found '
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W41'
  end

  ##
  # This will behave slightly different than the legacy jq based rule which was
  # targeted against inline ingress only
  def audit_impl(cfn_model)
    violating_security_groups = cfn_model.security_groups.select do |security_group|
      violating_ingresses = security_group.ingresses.select do |ingress|
        ingress.ipProtocol.to_i == -1
      end

      !violating_ingresses.empty?
    end

    violating_ingresses = cfn_model.standalone_ingress.select do |standalone_ingress|
      standalone_ingress.ipProtocol.to_i == -1
    end

    violating_security_groups.map(&:logical_resource_id) + violating_ingresses.map(&:logical_resource_id)
  end
end
