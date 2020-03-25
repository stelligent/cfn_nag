# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class ApiGatewayDeploymentUsagePlanRule < BaseRule
  def rule_text
    'AWS::ApiGateway::Deployment resources should be associated with an AWS::ApiGateway::UsagePlan. '
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W68'
  end

  def audit_impl(cfn_model)
    violating_api_deployments = cfn_model.resources_by_type('AWS::ApiGateway::Deployment').select do |deployment|
      deployment.usage_plan_ids.empty?
    end

    violating_api_deployments.map(&:logical_resource_id)
  end
end
