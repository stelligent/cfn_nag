# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class S3BucketPolicyNotPrincipalRule < BaseRule
  def rule_text
    'S3 Bucket policy should not allow Allow+NotPrincipal'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F9'
  end

  def audit_impl(cfn_model)
    violating_policies = cfn_model.resources_by_type('AWS::S3::BucketPolicy').select do |policy|
      !policy.policy_document.allows_not_principal.empty?
    end

    violating_policies.map(&:logical_resource_id)
  end
end
