# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class S3BucketPolicyWildcardPrincipalRule < BaseRule
  def rule_text
    'S3 Bucket policy should not allow * principal'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F16'
  end

  def audit_impl(cfn_model)
    logical_resource_ids = []

    cfn_model.resources_by_type('AWS::S3::BucketPolicy').each do |topic_policy|
      unless topic_policy.policy_document.wildcard_allowed_principals.empty?
        logical_resource_ids << topic_policy.logical_resource_id
      end
    end

    logical_resource_ids
  end
end
