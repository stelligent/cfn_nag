require 'spec_helper'
require 'cfn-nag/cfn_nag_config'
require 'cfn-nag/cfn_nag'

describe CfnNag do
  before(:all) do
    CfnNagLogging.configure_logging(debug: false)
    @cfn_nag = CfnNag.new(config: CfnNagConfig.new)
  end

  context 's3 with wildcards', :s3 do
    it 'flags a violation' do
      template_name = 'json/s3_bucket_policy/s3_bucket_with_wildcards.json'

      expected_aggregate_results = [
        {
          filename: test_template_path(template_name),
          file_results: {
            failure_count: 3,
            violations: [
              S3BucketPolicyWildcardActionRule.new.violation(%w[S3BucketPolicy S3BucketPolicy2], [61, 86], ["resource", "resource"]),
              S3BucketPolicyWildcardPrincipalRule.new.violation(%w[S3BucketPolicy2], [86], ["resource"])
            ]
          }
        }
      ]

      actual_aggregate_results = @cfn_nag.audit_aggregate_across_files input_path: test_template_path(template_name)
      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end
end
