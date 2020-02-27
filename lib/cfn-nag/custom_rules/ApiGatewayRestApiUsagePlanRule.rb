# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/api_gateway_usage_plan'
require_relative 'base'

class ApiGatewayRestApiUsagePlanRule < BaseRule
  def rule_text
    'All AWS::ApiGateway::RestApi resources should be associated with an AWS::ApiGateway::UsagePlan. '
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W64'
  end

  def audit_impl(cfn_model)
    _, usage_plan_rest_apis = usage_plan_stages_and_api_refs(cfn_model)

    violating_rest_apis = cfn_model.resources_by_type('AWS::ApiGateway::RestApi').select do |rest_api|
      violating_rest_apis?(usage_plan_rest_apis, rest_api)
    end

    violating_rest_apis.map(&:logical_resource_id)
  end

  private

  def violating_rest_apis?(usage_plan_rest_apis, rest_api)
    !usage_plan_rest_apis.include?(rest_api.logical_resource_id)
  end
end
