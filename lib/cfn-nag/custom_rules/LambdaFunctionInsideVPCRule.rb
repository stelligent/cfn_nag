# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class LambdaFunctionInsideVPCRule < BaseRule
  def rule_text
    'Lambda functions should be deployed inside a VPC, miss VpcConfig property'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W89'
  end

  def audit_impl(cfn_model)
    lambda_functions = cfn_model.resources_by_type('AWS::Lambda::Function')
    violating_lambda_functions = lambda_functions.select do |lambda_function|
      lambda_funcion.vpcConfig.nil?
    end
	
    violating_lambda_functions.map(&:logical_resource_id)
  end

end
