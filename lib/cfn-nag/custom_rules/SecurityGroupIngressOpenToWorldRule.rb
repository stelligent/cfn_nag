require 'cfn-nag/violation'
require_relative 'base'

class SecurityGroupIngressOpenToWorldRule < BaseRule

  def rule_text
    'Security Groups found with cidr open to world on ingress.  This should never be true on instance.  Permissible on ELB'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W2'
  end

  ##
  # This will behave slightly different than the legacy jq based rule which was targeted against inline ingress only
  def audit_impl(cfn_model)
    logical_resource_ids = []
    cfn_model.security_groups.each do |security_group|
      violating_ingresses = security_group.securityGroupIngress.select do |ingress|
        # only care about literals.  if a Hash/Ref not going to chase it down given likely a Parameter with external val
        ingress.cidrIp.is_a?(String) && ingress.cidrIp == '0.0.0.0/0'
      end

      unless violating_ingresses.empty?
        logical_resource_ids << security_group.logical_resource_id
      end
    end

    violating_ingresses = cfn_model.standalone_ingress.select do |standalone_ingress|
      standalone_ingress.cidrIp.is_a?(String) && standalone_ingress.cidrIp == '0.0.0.0/0'
    end

    logical_resource_ids + violating_ingresses.map { |ingress| ingress.logical_resource_id}
  end
end
