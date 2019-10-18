# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class IamRoleElevatedManagedPolicyRule < BaseRule
  def rule_text
    'IAM role should not have Elevated Managed policy'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W43'
  end

  def audit_impl(cfn_model)
    violating_roles = cfn_model.resources_by_type('AWS::IAM::Role').select do |role|
      role.managedPolicyArns.find do |policy|
        policy.include?('arn:aws:iam::aws:policy/AdministratorAccess') ||
          policy.include?('arn:aws:iam::aws:policy/PowerUserAccess') ||
          policy.include?('arn:aws:iam::aws:policy/IAMFullAccess')
      end
    end
    violating_roles.map(&:logical_resource_id)
  end
end
