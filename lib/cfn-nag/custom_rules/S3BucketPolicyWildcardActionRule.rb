# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class S3BucketPolicyWildcardActionRule < BaseRule
  def rule_text
    'S3 Bucket policy should not allow * action'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F15'
  end

  def audit_impl(cfn_model)
    logical_resource_ids = []

    cfn_model.resources_by_type('AWS::S3::BucketPolicy').each do |bucket_policy|
      unless bucket_policy.policy_document.wildcard_allowed_actions.empty?
        logical_resource_ids << bucket_policy.logical_resource_id
      end
    end

    logical_resource_ids
  end
end
