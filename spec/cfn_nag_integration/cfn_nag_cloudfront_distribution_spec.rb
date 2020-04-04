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
              Violation.new(
                id: 'W10', type: Violation::WARNING,
                message: 'CloudFront Distribution should enable access logging',
                logical_resource_ids: %w[rDistribution2],
                line_numbers: [46]
              ),
              Violation.new(
                id: 'W70', type: Violation::WARNING,
                message: 'Cloudfront should use minimum protocol version TLS 1.2',
                logical_resource_ids: ["rDistribution1", "rDistribution2"],
                line_numbers: [4,46]
              ),
              Violation.new(
                id: 'W51', type: Violation::WARNING,
                message: 'S3 bucket should likely have a bucket policy',
                logical_resource_ids: %w[S3Bucket],
                line_numbers: [81]
              )
            ]
          }
        }
      ]

      actual_aggregate_results = @cfn_nag.audit_aggregate_across_files input_path: test_template_path(template_name)
      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end
end
