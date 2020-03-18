# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class LambdaFunctionCloudWatchLogsRule < BaseRule
  def rule_text
    'Lambda functions require permission to write CloudWatch Logs'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W58'
  end

  def audit_impl(cfn_model)
    # Iterate over each Lambda function
    lambda_functions = cfn_model.resources_by_type('AWS::Lambda::Function')
    violating_lambda_functions = lambda_functions.select do |lambda_function|
      # Throw warning if no associated role object
      next lambda_function if lambda_function.role_object.nil?

      # Add lambda as violating if meets conditions
      violating_role?(lambda_function.role_object)
    end

    violating_lambda_functions.map(&:logical_resource_id)
  end

  def managed_policies_include_cw_logs_access?(managed_policies)
    !(managed_policies & ['arn:aws:iam::aws:policy/CloudWatchLogsFullAccess',
                          'arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole',
                          'arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole',
                          'arn:aws:iam::aws:policy/AWSLambdaExecute',
                          'arn:aws:iam::aws:policy/service-role/AWSLambdaKinesisExecutionRole',
                          'arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole',
                          'arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole']
     ).empty?
  end

  def inline_policies_include_cw_logs_access?(policies)
    policies.select do |policy|
      permissive_statements = policy.policy_document.statements.select do |statement|
        statement.allows_action?('logs:CreateLogGroup') && \
          statement.allows_action?('logs:CreateLogStream') && \
          statement.allows_action?('logs:PutLogEvents')
      end
      !permissive_statements.empty?
    end
  end

  def violating_role?(role)
    # Iterate over each policy in role
    permissive_policies = inline_policies_include_cw_logs_access?(role.policy_objects)

    # Iterate over each managed policy in role
    permissive_managed_policies = managed_policies_include_cw_logs_access?(role.managedPolicyArns)

    # Check if any policies violated
    permissive_policies.empty? && !permissive_managed_policies
  end
end
