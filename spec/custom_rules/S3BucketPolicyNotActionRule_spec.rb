require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/S3BucketPolicyNotActionRule'

describe S3BucketPolicyNotActionRule do
  context 's3 bucket policy with a NotAction' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/s3_bucket_policy/s3_bucket_policy_with_not_action.json')

      actual_logical_resource_ids = S3BucketPolicyNotActionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[S3BucketPolicyWithNotAction]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
