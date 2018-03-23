require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/S3BucketPublicReadAclRule'

describe S3BucketPublicReadAclRule do
  context 's3 bucket with a PublicRead ACL' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/s3_bucket/buckets_with_insecure_acl.json')

      actual_logical_resource_ids = S3BucketPublicReadAclRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[S3BucketRead]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
