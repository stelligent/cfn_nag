# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class MissingBucketPolicyRule < BaseRule
  def rule_text
    'S3 bucket should likely have a bucket policy'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W51'
  end

  def audit_impl(cfn_model)
    violating_buckets = cfn_model.resources_by_type('AWS::S3::Bucket').select do |bucket|
      policy_for_bucket(cfn_model, bucket).nil?
    end

    violating_buckets.map(&:logical_resource_id)
  end

  private

  def policy_for_bucket(cfn_model, bucket)
    cfn_model.resources_by_type('AWS::S3::BucketPolicy').find do |bucket_policy|
      if bucket_policy.bucket.is_a?(Hash) && bucket_policy.bucket.key?('Ref')
        bucket_policy.bucket['Ref'] == bucket.logical_resource_id
      else
        bucket.bucketName == bucket_policy.bucket
      end
    end
  end
end
