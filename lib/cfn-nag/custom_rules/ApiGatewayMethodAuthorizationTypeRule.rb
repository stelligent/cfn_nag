# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class ApiGatewayMethodAuthorizationTypeRule < BaseRule
  def rule_text
    "AWS::ApiGateway::Method should not have AuthorizationType set to 'NONE'. "
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W58'
  end

  def audit_impl(cfn_model)
    violating_deployments = cfn_model.resources_by_type('AWS::ApiGateway::Method').select do |method|
      method.authorizationType.nil? || method.authorizationType.to_s.casecmp('none').zero?
    end

    violating_deployments.map(&:logical_resource_id)
  end
end
