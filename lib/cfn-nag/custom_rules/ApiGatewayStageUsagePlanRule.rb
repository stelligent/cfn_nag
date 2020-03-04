# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/api_gateway_usage_plan'
require_relative 'base'

class ApiGatewayStageUsagePlanRule < BaseRule
  def rule_text
    'AWS::ApiGateway::Stage resources should be associated with an AWS::ApiGateway::UsagePlan. '
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W63'
  end

  def audit_impl(cfn_model)
    #usage_plan_stages = usage_plan_stages_and_api_refs(cfn_model)

    violating_api_gateway_stages = cfn_model.resources_by_type('AWS::ApiGateway::Stage').select do |api_stage|
      #violating_api_stages?(usage_plan_stages, api_stage)
      api_stage.usage_plan.nil?
    end

    violating_api_gateway_stages.map(&:logical_resource_id)
  end

  private

  # def violating_api_stages?(usage_plan_stages, api_stage)
  #   !usage_plan_stages.include?(api_stage.logical_resource_id)
  # end
end
