# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class ElasticLoadBalancerV2AccessLoggingRule < BaseRule
  def rule_text
    'Elastic Load Balancer V2 should have access logging enabled'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W52'
  end

  def audit_impl(cfn_model)
    violating_elbs = cfn_model.resources_by_type('AWS::ElasticLoadBalancingV2::LoadBalancer')
                              .select do |elb|      
      elb.loadBalancerAttributes.nil? || elb.loadBalancerAttributes.find{ |k| k['Key'] ==  'access_logs.s3.enabled'}.nil? ||  elb.loadBalancerAttributes.find{ |k| k['Key'] ==  'access_logs.s3.enabled' && k['Value'] == 'false'} 
    end

    violating_elbs.map(&:logical_resource_id)
  end
end
