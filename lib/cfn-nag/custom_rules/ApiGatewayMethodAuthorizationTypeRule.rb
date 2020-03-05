# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class ApiGatewayMethodAuthorizationTypeRule < BaseRule
  def rule_text
    "AWS::ApiGateway::Method should not have AuthorizationType set to 'NONE' unless it is of " \
    'HttpMethod: OPTIONS.'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W59'
  end

  def audit_impl(cfn_model)
    violating_methods = cfn_model.resources_by_type('AWS::ApiGateway::Method').select do |method|
      violating_method?(method)
    end

    violating_methods.map(&:logical_resource_id)
  end

  private

  def violating_method?(method)
    unless method.httpMethod.to_s.casecmp('options').zero?
      method.authorizationType.nil? || method.authorizationType.to_s.casecmp('none').zero?
    end
  end
end
