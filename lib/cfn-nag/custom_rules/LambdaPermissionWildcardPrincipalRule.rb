require 'cfn-nag/violation'
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
    violating_lambdas = cfn_model.resources_by_type('AWS::Lambda::Permission').select do |lambda_permission|
      Principal.wildcard? lambda_permission.principal
    end

    violating_lambdas.map { |violating_lambda| violating_lambda.logical_resource_id }
  end
end
