# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class ResourceWithCustomNameRule < BaseRule

  # The values of this hash are camel-cased, due to cfn-model returning
  # camel cased values. E.g. GroupName in CloudFormation is returned by
  # cfn-model as groupName, RoleName is returned as roleName, etc.
  RESOURCE_NAME_MAPPING = {
    'AWS::IAM::Role': 'roleName',
    'AWS::EC2::SecurityGroup': 'groupName'
  }.freeze

  def rule_text
    'Resources found with a custom name, this disallows updates that ' \
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
      resources = cfn_model.resources_by_type(cfn_resource.to_s)
                          .select do |resource|
        !resource.send(key_name).nil?
      end

      violating_resources << resources.map(&:logical_resource_id)
    end

    violating_resources.flatten
  end
end
