# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class ApiGatewaySecurityPolicyRule < BaseRule
  def rule_text
    'ApiGateway SecurityPolicy should use TLS 1.2'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W62'
  end

  def audit_impl(cfn_model)
    violating_domains = cfn_model.resources_by_type('AWS::ApiGateway::DomainName').select do |domain|
      domain.securityPolicy.nil? || domain.securityPolicy == 'TLS_1_0'
    end

    violating_domains.map(&:logical_resource_id)
  end
end
