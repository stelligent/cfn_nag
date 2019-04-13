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
    logical_resource_ids = []

    cfn_model.resources_by_type('AWS::S3::Bucket').each do |bucket|
      next unless bucket.accessControl == 'PublicReadWrite'
      logical_resource_ids << bucket.logical_resource_id
    end

    logical_resource_ids
  end
end
