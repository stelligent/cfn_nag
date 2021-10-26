require 'spec_helper'
require 'cfn-nag/cfn_nag_config'
require 'cfn-nag/cfn_nag'

describe CfnNag do
  before(:all) do
    CfnNagLogging.configure_logging(debug: false)
    @cfn_nag = CfnNag.new(config: CfnNagConfig.new)
  end

  context 'two buckets with insecure ACL - PublicRead and PublicReadWrite' do
    it 'flags a warning and a violation' do
      template_name = 'json/s3_bucket/buckets_with_insecure_acl.json'

      expected_aggregate_results = [
        {
          filename: test_template_path(template_name),
          file_results: {
            failure_count: 1,
            violations: [
              MissingBucketPolicyRule.new.violation(%w[S3BucketRead S3BucketReadWrite], [4, 24], ["resource", "resource"]),
              S3BucketPublicReadAclRule.new.violation(%w[S3BucketRead], [4], ["resource"]),
              S3BucketPublicReadWriteAclRule.new.violation(%w[S3BucketReadWrite], [24], ["resource"])
            ]
          }
        }
      ]

      actual_aggregate_results = @cfn_nag.audit_aggregate_across_files input_path: test_template_path(template_name)
      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end
end
