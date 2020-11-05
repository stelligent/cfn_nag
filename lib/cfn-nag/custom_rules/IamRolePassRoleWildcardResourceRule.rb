# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'
require 'cfn-nag/util/wildcard_patterns'

class IamRolePassRoleWildcardResourceRule < BaseRule
  IAM_ACTION_PATTERNS = wildcard_patterns('PassRole').map! { |x| "iam:#{x}" } + ['*']

  def rule_text
    'IAM role should not allow * resource with PassRole action on its permissions policy'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F38'
  end

  def audit_impl(cfn_model)
    violating_roles = cfn_model.resources_by_type('AWS::IAM::Role').select do |role|
      violating_policies = role.policy_objects.select do |policy|
        violating_statements = policy.policy_document.statements.select do |statement|
          passrole_action?(statement) && wildcard_resource?(statement)
        end
        !violating_statements.empty?
      end
      !violating_policies.empty?
    end
    violating_roles.map(&:logical_resource_id)
  end

  private

  def passrole_action?(statement)
    statement.actions.find { |action| IAM_ACTION_PATTERNS.include? action }
  end

  def wildcard_resource?(statement)
    statement.resources.find { |resource| resource == '*' }
  end
end
