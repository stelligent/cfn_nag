# frozen_string_literal: true

require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/LambdaFunctionCloudWatchLogsRule'

describe LambdaFunctionCloudWatchLogsRule do
  describe 'AWS::Lambda::Function' do
    context 'when function\'s role contains logs:PutLogEvents or equivalent wildcard' do
      it 'does not return an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/lambda_function/lambda_with_cloudwatch_logs_permission.json')
        actual_logical_resource_ids = LambdaFunctionCloudWatchLogsRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end

    context 'when function\'s role does not contain logs:PutLogEvents or equivalent wildcard' do
      it 'returns an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/lambda_function/lambda_without_cloudwatch_logs_permission.json')
        actual_logical_resource_ids = LambdaFunctionCloudWatchLogsRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq %w[
          FunctionWithWildcardDynamoDbRoleByRef
          FunctionWithWildcardDynamoDbRoleByFnGetAtt
          FunctionWithPartialLogsPermsRoleByRef
        ]
      end
    end

    context 'when function\'s role contains CloudWatchLogsFullAccess managed policy' do
      it 'does not return an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/lambda_function/lambda_with_cloudwatch_logs_managed_policy.json')
        actual_logical_resource_ids = LambdaFunctionCloudWatchLogsRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end

    context 'when function\'s role contains AWSLambdaBasicExecutionRole managed policy' do
      it 'does not return an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/lambda_function/lambda_with_lambda_basic_managed_policy.json')
        actual_logical_resource_ids = LambdaFunctionCloudWatchLogsRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end

    context 'when function\'s role contains AWSLambdaDynamoDBExecutionRole managed policy' do
      it 'does not return an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/lambda_function/lambda_with_lambda_dynamodb_managed_policy.json')
        actual_logical_resource_ids = LambdaFunctionCloudWatchLogsRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end

    context 'when function\'s role contains AWSLambdaExecute managed policy' do
      it 'does not return an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/lambda_function/lambda_with_lambda_execute_managed_policy.json')
        actual_logical_resource_ids = LambdaFunctionCloudWatchLogsRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end

    context 'when function\'s role contains AWSLambdaKinesisExecutionRole managed policy' do
      it 'does not return an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/lambda_function/lambda_with_lambda_kinesis_managed_policy.json')
        actual_logical_resource_ids = LambdaFunctionCloudWatchLogsRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end

    context 'when function\'s role contains AWSLambdaSQSQueueExecutionRole managed policy' do
      it 'does not return an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/lambda_function/lambda_with_lambda_sqs_managed_policy.json')
        actual_logical_resource_ids = LambdaFunctionCloudWatchLogsRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end

    context 'when function\'s role contains AWSLambdaVPCAccessExecutionRole managed policy' do
      it 'does not return an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/lambda_function/lambda_with_lambda_vpc_managed_policy.json')
        actual_logical_resource_ids = LambdaFunctionCloudWatchLogsRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end

    context 'when function\'s role contains managed policy without CloudWatch Logs access' do
      it 'returns an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/lambda_function/lambda_with_other_managed_policies.json')
        actual_logical_resource_ids = LambdaFunctionCloudWatchLogsRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq %w[
          FunctionWithOtherManagedPolicyRoleByRef
        ]
      end
    end

    context 'when a combination of functions contain managed policy with and without CloudWatch Logs access' do
      it 'returns an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/lambda_function/lambda_with_managed_policies.json')
        actual_logical_resource_ids = LambdaFunctionCloudWatchLogsRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq %w[
          FunctionWithOtherManagedPolicyRoleByRef
        ]
      end
    end

    context 'when function\'s role does not exist in the same template' do
      it 'returns an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/lambda_function/lambda_with_role_elsewhere.json')
        actual_logical_resource_ids = LambdaFunctionCloudWatchLogsRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq %w[
          FunctionWithRoleFromParameter
          FunctionWithRoleStringArn
        ]
      end
    end
  end
end
