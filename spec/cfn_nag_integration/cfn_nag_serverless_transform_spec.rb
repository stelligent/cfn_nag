require 'spec_helper'
require 'cfn-nag/cfn_nag_config'
require 'cfn-nag/cfn_nag'

describe CfnNag do
  before(:all) do
    CfnNagLogging.configure_logging(debug: false)
    @cfn_nag = CfnNag.new(config: CfnNagConfig.new)
  end

  # the heavy lifting for dealing with metadata is down in cfn-model.  just make sure we've got a good version
  # of the parser that doesn't blow up
  context 'serverless function with metadata', :lambda do
    it 'parses properly' do
      template_name = 'yaml/sam/metadata.yml'
      actual_aggregate_results = @cfn_nag.audit_aggregate_across_files input_path: test_template_path(template_name)

      expected_aggregate_results = [
        {
          filename: test_template_path(template_name),
          file_results: {
            failure_count: 0,
            violations: [
              LambdaFunctionCloudWatchLogsRule.new.violation(%w[SomeFunction2], [34]),
              LambdaFunctionInsideVPCRule.new.violation(["SomeFunction", "SomeFunction2"], [20, 34]),
              LambdaFunctionReservedConcurrentExecutionsRule.new.violation(["SomeFunction","SomeFunction2"], [20, 34])
            ]
          }
        }
      ]

      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end
end
