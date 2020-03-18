# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class ApiGatewayStageAccessLoggingRule < BaseRule
  def rule_text
    'AWS::ApiGateway::Stage should have the AccessLogSetting property defined.'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W69'
  end

  def audit_impl(cfn_model)
    violating_api_gateway_stages = cfn_model.resources_by_type('AWS::ApiGateway::Stage').select do |api_stage|
      api_stage.accessLogSetting.nil?
    end

    violating_api_gateway_stages.map(&:logical_resource_id)
  end
end
