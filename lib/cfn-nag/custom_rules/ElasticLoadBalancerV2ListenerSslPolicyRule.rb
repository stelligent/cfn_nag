# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class ElasticLoadBalancerV2ListenerSslPolicyRule < BaseRule
  def rule_text
    'Elastic Load Balancer V2 Listener SslPolicy should use TLS 1.2'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W55'
  end

  def audit_impl(cfn_model)
    violating_listeners = cfn_model.resources_by_type('AWS::ElasticLoadBalancingV2::Listener')
                                   .select do |listener|
      violating_listeners?(listener)
    end

    violating_listeners.map(&:logical_resource_id)
  end

  private

  def violating_listeners?(listener)
    if %w[HTTPS TLS].include?(listener.protocol)
      listener.sslPolicy.nil? ||
        %w[ELBSecurityPolicy-2016-08 ELBSecurityPolicy-TLS-1-0-2015-04
           ELBSecurityPolicy-TLS-1-1-2017-01 ELBSecurityPolicy-FS-2018-06
           ELBSecurityPolicy-FS-1-1-2019-08 ELBSecurityPolicy-2015]
          .include?(listener.sslPolicy)
    else
      false
    end
  end
end
