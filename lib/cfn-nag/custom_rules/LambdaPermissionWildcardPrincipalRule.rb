# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-model/model/lambda_principal'
require_relative 'base'

class LambdaPermissionWildcardPrincipalRule < BaseRule
  def rule_text
    'Lambda permission principal should not be wildcard'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F13'
  end

  def audit_impl(cfn_model)
    lambda_permissions = cfn_model.resources_by_type('AWS::Lambda::Permission')
    violating_lambda_permissions = lambda_permissions.select do |lambda_permission|
      LambdaPrincipal.wildcard? lambda_permission.principal
    end

    violating_lambda_permissions.map(&:logical_resource_id)
  end
end
