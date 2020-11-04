# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/truthy'
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
      elb.loadBalancerAttributes.nil? || missing_access_logs?(elb) || access_logging_is_false?(elb)
    end

    violating_elbs.map(&:logical_resource_id)
  end

  private

  def access_logging_is_false?(load_balancer)
    load_balancer.loadBalancerAttributes.find do |load_balancer_attribute|
      load_balancer_attribute['Key'] == 'access_logs.s3.enabled' && not_truthy?(load_balancer_attribute['Value'])
    end
  end

  def missing_access_logs?(load_balancer)
    access_log_attribute = load_balancer.loadBalancerAttributes.find do |load_balancer_attribute|
      load_balancer_attribute['Key'] == 'access_logs.s3.enabled'
    end
    access_log_attribute.nil?
  end
end
