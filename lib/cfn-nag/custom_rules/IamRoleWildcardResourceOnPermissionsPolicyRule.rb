# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class IamRoleWildcardResourceOnPermissionsPolicyRule < BaseRule
  def rule_text
    'IAM role should not allow * resource on its permissions policy'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W11'
  end

  def audit_impl(cfn_model)
    violating_roles = cfn_model.resources_by_type('AWS::IAM::Role').select do |role|
      violating_policies = role.policy_objects.select do |policy|
        !policy.policy_document.wildcard_allowed_resources.empty?
      end
      !violating_policies.empty?
    end

    violating_roles.map(&:logical_resource_id)
  end
end
