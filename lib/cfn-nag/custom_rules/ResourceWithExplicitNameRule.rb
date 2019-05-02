# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class ResourceWithExplicitNameRule < BaseRule
  # The values of this hash are camel-cased, due to cfn-model returning
  # camel cased values. E.g. GroupName in CloudFormation is returned by
  # cfn-model as groupName, RoleName is returned as roleName, etc.
  RESOURCE_NAME_MAPPING = {
    'AWS::ApiGateway::ApiKey' => 'name',
    'AWS::CloudWatch::Alarm' => 'alarmName',
    'AWS::CodeDeploy::DeploymentConfig' => 'deploymentConfigName',
    'AWS::CodeDeploy::DeploymentGroup' => 'deploymentGroupName',
    'AWS::DynamoDB::Table' => 'tableName',
    'AWS::EC2::SecurityGroup' => 'groupName',
    'AWS::ECR::Repository' => 'repositoryName',
    'AWS::ElasticLoadBalancingV2::LoadBalancer' => 'name',
    'AWS::Elasticsearch::Domain' => 'domainName',
    'AWS::IAM::Group' => 'groupName',
    'AWS::IAM::ManagedPolicy' => 'managedPolicyName',
    'AWS::IAM::Role' => 'roleName',
    'AWS::Kinesis::Stream' => 'name',
    'AWS::RDS::DBInstance' => 'dBInstanceIdentifier'
  }.freeze

  def rule_text
    'Resource found with an explicit name, this disallows updates that ' \
    'require replacement of this resource'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W28'
  end

  def audit_impl(cfn_model)
    violating_resources = []

    RESOURCE_NAME_MAPPING.each do |cfn_resource, key_name|
      resources = cfn_model.resources_by_type(cfn_resource)
                           .select do |resource|
        explicitly_set_resource_name?(resource, key_name)
      end

      violating_resources << resources.map(&:logical_resource_id)
    end

    violating_resources.flatten
  end

  private

  def explicitly_set_resource_name?(resource, key_name)
    !resource.send(key_name).nil?
  end
end
