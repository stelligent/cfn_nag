require 'spec_helper'
require 'cfn-nag/cfn_nag'

describe CfnNag do
  before(:all) do
    CfnNag.configure_logging(debug: false)
    @cfn_nag = CfnNag.new
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
              Violation.new(
                id: 'W31', type: Violation::WARNING,
                message: 'S3 Bucket likely should not have a public read acl',
                logical_resource_ids: %w[S3BucketRead]
              ),
              Violation.new(id: 'F14',
                            type: Violation::FAILING_VIOLATION,
                            message:
                            'S3 Bucket should not have a public read-write acl',
                            logical_resource_ids: %w[S3BucketReadWrite])
            ]
          }
        }
      ]

      actual_aggregate_results = @cfn_nag.audit_aggregate_across_files input_path: test_template_path(template_name)
      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end
end
