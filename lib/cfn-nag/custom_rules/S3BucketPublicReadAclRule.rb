# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class S3BucketPublicReadAclRule < BaseRule
  def rule_text
    'S3 Bucket likely should not have a public read acl'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W31'
  end

  def audit_impl(cfn_model)
    logical_resource_ids = []

    cfn_model.resources_by_type('AWS::S3::Bucket').each do |bucket|
      logical_resource_ids << bucket.logical_resource_id if bucket.accessControl == 'PublicRead'
    end

    logical_resource_ids
  end
end
