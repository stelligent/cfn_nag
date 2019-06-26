# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class IamRolePassRoleWildcardResourceRule < BaseRule
  def rule_text
    'IAM role can not use a * resource with a PassRole action on its inline policy'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'WXX'
  end

  def PassRoleAction?(statement)
    statement.actions.find{ |action| action == "iam:PassRole"}
  end

  def WildcardAction?(statement)
    statement.resources.find{ |resource| resource == "*"}
  end

  def audit_impl(cfn_model)
    violating_roles = cfn_model.resources_by_type('AWS::IAM::Role').select do |role|
      violating_policies = role.policy_objects.select do |policy|
        violating_statements = policy.policy_document.statements.select do |statement|
          PassRoleAction?(statement) && WildcardAction?(statement) 
        end
          !violating_statements.empty?
      end
      !violating_policies.empty?
    end
    violating_roles.map(&:logical_resource_id)
  end
end
