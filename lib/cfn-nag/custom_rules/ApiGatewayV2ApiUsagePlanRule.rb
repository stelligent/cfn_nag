# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/api_gateway_usage_plan'
require_relative 'base'

class ApiGatewayV2ApiUsagePlanRule < BaseRule
  def rule_text
    "AWS::ApiGatewayV2::Api resources (with 'ProtocolType: WEBSOCKET') should be associated with an " \
      'AWS::ApiGateway::UsagePlan. '
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W66'
  end

  def audit_impl(cfn_model)
    _, usage_plan_v2_apis = usage_plan_stages_and_api_refs(cfn_model)

    violating_v2_apis = cfn_model.resources_by_type('AWS::ApiGatewayV2::Api').select do |v2_api|
      violating_v2_apis?(usage_plan_v2_apis, v2_api)
    end

    violating_v2_apis.map(&:logical_resource_id)
  end

  private

  def violating_v2_apis?(usage_plan_v2_apis, v2_api)
    if v2_api.protocolType.casecmp?('websocket')
      !usage_plan_v2_apis.include?(v2_api.logical_resource_id)
    end
  end
end
