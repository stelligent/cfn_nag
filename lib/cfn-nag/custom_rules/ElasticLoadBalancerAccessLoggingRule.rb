# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class ElasticLoadBalancerAccessLoggingRule < BaseRule
  def rule_text
    'Elastic Load Balancer should have access logging enabled'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W26'
  end

  def audit_impl(cfn_model)
    violating_elbs = cfn_model.resources_by_type('AWS::ElasticLoadBalancing::LoadBalancer')
                              .select do |elb|
      elb.accessLoggingPolicy.nil? || elb.accessLoggingPolicy['Enabled'] != true
    end

    violating_elbs.map(&:logical_resource_id)
  end
end
