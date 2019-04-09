# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class LambdaPermissionInvokeFunctionActionRule < BaseRule
  def rule_text
    'Lambda permission beside InvokeFunction might not be what you want?  Not sure!?'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W24'
  end

  def audit_impl(cfn_model)
    violating_lambdas = cfn_model.resources_by_type('AWS::Lambda::Permission').reject do |lambda_permission|
      lambda_permission.action == 'lambda:InvokeFunction'
    end

    violating_lambdas.map(&:logical_resource_id)
  end
end
