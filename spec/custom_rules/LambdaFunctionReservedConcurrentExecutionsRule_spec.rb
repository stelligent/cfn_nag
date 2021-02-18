# frozen_string_literal: true

require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/LambdaFunctionReservedConcurrentExecutionsRule'

describe LambdaFunctionReservedConcurrentExecutionsRule do

  describe 'AWS::Lambda::Function' do
    context 'when Lambda functions defines ReservedConcurrentExecutions to reserve simultaneous executions' do
      it 'does not return an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/lambda_function/lambda_reserved_executions.json')
        actual_logical_resource_ids = LambdaFunctionReservedConcurrentExecutionsRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end
  end

  describe 'AWS::Lambda::Function' do
    context 'when Lambda functions does not define ReservedConcurrentExecutions to reserve simultaneous executions' do
      it 'does return an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/lambda_function/lambda_not_reserved_executions.json')
        actual_logical_resource_ids = LambdaFunctionReservedConcurrentExecutionsRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq ["FunctionNotReserved"]
      end
    end
   end
   
end