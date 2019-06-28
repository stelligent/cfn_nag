# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'
require 'cfn-nag/util/iam_permutations'

class PassRoleBaseRule < BaseRule
  PASSROLE_WILDCARD_PERMUTATIONS = iam_permutations(string = 'PassRole', element = 'action', prefix = 'iam:')

  def policy_type
    raise 'must implement in subclass'
  end

  def audit_impl(cfn_model)
    policies = cfn_model.resources_by_type(policy_type)

    violating_policies = policies.select do |policy|
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
