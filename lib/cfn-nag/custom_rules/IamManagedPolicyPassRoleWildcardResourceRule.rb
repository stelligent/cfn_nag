# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'
require 'cfn-nag/util/iam_permutations'

PASSROLE_WILDCARD_PERMUTATIONS = iam_permutations(string = 'PassRole', element = 'action', prefix = 'iam:')

class IamManagedPolicyPassRoleWildcardResourceRule < BaseRule
  def rule_text
    'IAM managed policy should not allow a * resource with PassRole action'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F40'
  end

  def audit_impl(cfn_model)
    violating_policies = cfn_model.resources_by_type('AWS::IAM::ManagedPolicy').select do |policy|
      violating_statements = policy.policy_document.statements.select do |statement|
        passrole_action?(statement) && wildcard_resource?(statement)
      end
      !violating_statements.empty?
    end
    violating_policies.map(&:logical_resource_id)
  end

  private

  def passrole_action?(statement)
    statement.actions.find { |action| PASSROLE_WILDCARD_PERMUTATIONS.include? action }
  end

  def wildcard_resource?(statement)
    statement.resources.find { |resource| resource == '*' }
  end
end
