require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/S3BucketEncryptionSetRule'

describe S3BucketEncryptionSetRule do
  context 's3 bucket with encryption set' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/s3_bucket/buckets_with_no_encryption.json')

      actual_logical_resource_ids = S3BucketEncryptionSetRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[S3BucketEncryptionNotSet]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end