# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class ElasticLoadBalancerV2ListenerProtocolRule < BaseRule
  def rule_text
    'Elastic Load Balancer V2 Listener Protocol should use HTTPS for ALBs'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W56'
  end

  def audit_impl(cfn_model)
    violating_listeners = cfn_model.resources_by_type('AWS::ElasticLoadBalancingV2::Listener')
                                   .select do |listener|
      listener.protocol == 'HTTP'
    end

    violating_listeners.map(&:logical_resource_id)
  end
end
