# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class S3BucketPublicReadWriteAclRule < BaseRule
  def rule_text
    'S3 Bucket should not have a public read-write acl'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F14'
  end

  def audit_impl(cfn_model)
    violating_buckets = cfn_model.resources_by_type('AWS::S3::Bucket').select do |bucket|
      bucket.accessControl == 'PublicReadWrite'
    end

    violating_buckets.map(&:logical_resource_id)
  end
end
