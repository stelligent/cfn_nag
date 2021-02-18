# frozen_string_literal: true

require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/LambdaFunctionInsideVPCRule'

describe LambdaFunctionInsideVPCRule do

  describe 'AWS::Lambda::Function' do
    context 'when lambda function is inside VPC' do
      it 'does not return an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/lambda_function/lambda_inside_vpc.json')
        actual_logical_resource_ids = LambdaFunctionInsideVPCRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end
  end

  describe 'AWS::Lambda::Function' do
    context 'when lambda function is not inside VPC' do
      it 'does return an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/lambda_function/lambda_not_inside_vpc.json')
        actual_logical_resource_ids = LambdaFunctionInsideVPCRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq ["FunctionNotInsideVpc"]
      end
    end
   end
   
end
