# frozen_string_literal: true

require 'cfn-nag/util/wildcard_patterns'
require 'cfn-nag/violation'
require_relative 'base'

class LambdaFunctionCloudWatchLogsRule < BaseRule
  IAM_CREATEGROUP_PATTERNS = wildcard_patterns('CreateLogGroup').map! { |x| 'logs:' + x } + ['*']
  IAM_CREATESTREAM_PATTERNS = wildcard_patterns('CreateLogStream').map! { |x| 'logs:' + x } + ['*']
  IAM_PUTEVENT_PATTERNS = wildcard_patterns('PutLogEvent').map! { |x| 'logs:' + x } + ['*']

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
      # Determine how the role is assigned to the function
      # and get the role ID
      next lambda_function if lambda_function.role.instance_of? String

      # Find role in template if exists
      role_resources = find_role_by_id?(cfn_model, compute_role_id?(lambda_function.role.values[0]))

      # Add lambda as violating if meets conditions
      violating_roles = find_violating_roles?(role_resources)
      role_resources.empty? || !violating_roles.empty?
    end

    violating_lambda_functions.map(&:logical_resource_id)
  end

  def creategroup_action?(statement)
    statement.actions.find { |action| IAM_CREATEGROUP_PATTERNS.include? action }
  end

  def createstream_action?(statement)
    statement.actions.find { |action| IAM_CREATESTREAM_PATTERNS.include? action }
  end

  def putevent_action?(statement)
    statement.actions.find { |action| IAM_PUTEVENT_PATTERNS.include? action }
  end

  def compute_role_id?(role_value)
    role_value.instance_of?(String) ? role_value.split('.')[0] : role_value[0]
  end

  def find_role_by_id?(model, role_id)
    model.resources.values.select { |resource| resource.logical_resource_id == role_id }
  end

  def evaluate_managed_policies?(managed_policies)
    managed_policies.include?('arn:aws:iam::aws:policy/CloudWatchLogsFullAccess') || \
      managed_policies.include?('arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole')
  end

  def find_violating_roles?(roles)
    roles.select do |role|
      # Iterate over each policy in role
      permissive_policies = role.policy_objects.select do |policy|
        permissive_statements = policy.policy_document.statements.select do |statement|
          creategroup_action?(statement) && \
            createstream_action?(statement) && \
            putevent_action?(statement)
        end
        !permissive_statements.empty?
      end

      # Iterate over each managed policy in role
      permissive_managed_policies = evaluate_managed_policies?(role.managedPolicyArns)

      # Check if any policies violated
      permissive_policies.empty? && !permissive_managed_policies
    end
  end
end
