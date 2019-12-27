require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/MissingBucketPolicyRule'

describe MissingBucketPolicyRule do
  context 'bucket without bucket policy' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
                                        'yaml/s3/bucket_with_no_policy.yml'
                                      )

      actual_logical_resource_ids = MissingBucketPolicyRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[Bucket2]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'bucket with bucket policy' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
                                        'yaml/s3/bucket_with_non_literal_policy.yml'
                                      )

      actual_logical_resource_ids = MissingBucketPolicyRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
