require 'spec_helper'
require 'cfn-nag/cfn_nag_config'
require 'cfn-nag/cfn_nag'

describe CfnNag do
  before(:all) do
    CfnNagLogging.configure_logging(debug: false)
    @cfn_nag = CfnNag.new(config: CfnNagConfig.new)
  end

  context 'cloudfront distro without logging', :cf do
    it 'flags a warning' do
      template_name = 'json/cloudfront_distribution/cloudfront_distribution_without_logging.json'

      expected_aggregate_results = [
        {
          filename: test_template_path(template_name),
          file_results: {
            failure_count: 0,
            violations: [
              CloudFrontDistributionAccessLoggingRule.new.violation(%w[rDistribution2], [46]),
              CloudfrontMinimumProtocolVersionRule.new.violation(["rDistribution1", "rDistribution2"], [4,46]),
              MissingBucketPolicyRule.new.violation(%w[S3Bucket], [81])
            ]
          }
        }
      ]

      actual_aggregate_results = @cfn_nag.audit_aggregate_across_files input_path: test_template_path(template_name)
      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end
end
