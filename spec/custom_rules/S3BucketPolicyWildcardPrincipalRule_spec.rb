require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/S3BucketPolicyWildcardPrincipalRule'

describe S3BucketPolicyWildcardPrincipalRule do
  context 's3 bucket policy with a wildcard Principal' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/s3_bucket_policy/s3_bucket_with_wildcards.json')

      actual_logical_resource_ids = S3BucketPolicyWildcardPrincipalRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[S3BucketPolicy2]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
