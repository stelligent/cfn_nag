require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/CloudFrontDistributionAccessLoggingRule'

describe CloudFrontDistributionAccessLoggingRule do
  context 'distribution without logging' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'json/cloudfront_distribution/cloudfront_distribution_without_logging.json'
      )

      actual_logical_resource_ids = CloudFrontDistributionAccessLoggingRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[rDistribution2]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
