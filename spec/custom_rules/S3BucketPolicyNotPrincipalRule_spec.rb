require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/S3BucketPolicyNotPrincipalRule'

describe S3BucketPolicyNotPrincipalRule do
  context 's3 bucket policy with a NotPrincipal' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/s3_bucket_policy/s3_bucket_policy_with_not_principal.json')

      actual_logical_resource_ids = S3BucketPolicyNotPrincipalRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[S3BucketPolicy]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
