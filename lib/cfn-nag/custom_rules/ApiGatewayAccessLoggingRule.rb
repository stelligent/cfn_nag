# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class ApiGatewayAccessLoggingRule < BaseRule
  def rule_text
    'ApiGateway should have access logging configured'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W45'
  end

  def audit_impl(cfn_model)
    violating_deployments = cfn_model.resources_by_type('AWS::ApiGateway::Deployment').select do |deployment|
      deployment.stageDescription.nil? || deployment.stageDescription['AccessLogSetting'].nil?
    end

    violating_deployments.map(&:logical_resource_id)
  end
end
