# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

#TODO: assign/check unique W rule number

class S3BucketEncryptionSetRule < BaseRule
  def rule_text
    'S3 Bucket should have encryption option set'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W40'
  end

  def audit_impl(cfn_model)
    violating_buckets = cfn_model.resources_by_type('AWS::S3::Bucket').each do |bucket|
       bucket.bucketEncryption.nil?
    end

    violating_buckets.map(&:logical_resource_id)
  end

end
