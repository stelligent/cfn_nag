# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/api_gateway_usage_plan'
require_relative 'base'

class ApiGatewayV2StageUsagePlanRule < BaseRule
  def rule_text
    'AWS::ApiGatewayV2::Stage resources should be associated with an AWS::ApiGateway::UsagePlan. '
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W65'
  end

  def audit_impl(cfn_model)
    usage_plan_v2_stages, = usage_plan_stages_and_api_refs(cfn_model)

    violating_apigw_v2_stages = cfn_model.resources_by_type('AWS::ApiGatewayV2::Stage').select do |api_v2_stage|
      violating_api_v2_stages?(usage_plan_v2_stages, api_v2_stage)
    end

    violating_apigw_v2_stages.map(&:logical_resource_id)
  end

  private

  def violating_api_v2_stages?(usage_plan_stages, api_v2_stage)
    !usage_plan_stages.include?(api_v2_stage.logical_resource_id)
  end
end
