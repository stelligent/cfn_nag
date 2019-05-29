require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/S3BucketAccessLoggingRule'

describe S3BucketAccessLoggingRule do
  context 'S3 Bucket has no access logging configured' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/s3_bucket/buckets_with_no_access_logging.json')

      actual_logical_resource_ids = S3BucketAccessLoggingRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[S3BucketNoAccessLogging]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'S3 Bucket should has access logging configured' do
    it 'returns empty' do
      cfn_model = CfnParser.new.parse read_test_template('json/s3_bucket/buckets_with_access_logging.json')

      actual_logical_resource_ids = S3BucketAccessLoggingRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
