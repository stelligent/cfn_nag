require 'cfn-nag/violation'
require_relative 'base'

class IamManagedPolicyWildcardResourceRule < BaseRule

  def rule_text
    'IAM managed policy should not allow * resource'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W13'
  end

  def audit_impl(cfn_model)
    violating_policies = cfn_model.resources_by_type('AWS::IAM::ManagedPolicy').select do |policy|
      !policy.policyDocument.wildcard_allowed_resources.empty?
    end

    violating_policies.map { |policy| policy.logical_resource_id }
  end
end
