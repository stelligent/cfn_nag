# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class ApiGatewayV2AccessLoggingRule < BaseRule
  def rule_text
    'ApiGateway V2 should have access logging configured'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W46'
  end

  def audit_impl(cfn_model)
    violating_deployments = cfn_model.resources_by_type('AWS::ApiGatewayV2::Stage').select do |deployment|
      deployment.accessLogSettings.nil?
    end

    violating_deployments.map(&:logical_resource_id)
  end
end
