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
    'W55'
  end

  def audit_impl(cfn_model)
    # Iterate over each Lambda function
    lambda_functions = cfn_model.resources_by_type('AWS::Lambda::Function')
    violating_lambda_functions = lambda_functions.select do |lambda_function|
      # Throw warning if role is a string ARN
      next lambda_function if lambda_function.role.instance_of? String

      # Find role in template if exists
      # If ID not in template, add lambda to violations and continue
      role_resources = cfn_model.resources_by_id(lambda_function.role_id)
      next lambda_function if role_resources.empty?

      # Add lambda as violating if meets conditions
      role_violations = violating_roles?(role_resources)
      !role_violations.empty?
    end

    violating_lambda_functions.map(&:logical_resource_id)
  end

  def managed_policies_include_cw_logs_access?(managed_policies)
    managed_policies.include?('arn:aws:iam::aws:policy/CloudWatchLogsFullAccess') || \
      managed_policies.include?('arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole')
  end

  def inline_policies_include_cw_logs_access?(policies)
    policies.select do |policy|
      permissive_statements = policy.policy_document.statements.select do |statement|
        statement.allows_action?('logs:CreateLogGroup') && \
          statement.allows_action?('logs:CreateLogStream') && \
          statement.allows_action?('logs:PutLogEvent')
      end
      !permissive_statements.empty?
    end
  end

  def violating_roles?(roles)
    roles.select do |role|
      # Iterate over each policy in role
      permissive_policies = inline_policies_include_cw_logs_access?(role.policy_objects)

      # Iterate over each managed policy in role
      permissive_managed_policies = managed_policies_include_cw_logs_access?(role.managedPolicyArns)

      # Check if any policies violated
      permissive_policies.empty? && !permissive_managed_policies
    end
  end
end
