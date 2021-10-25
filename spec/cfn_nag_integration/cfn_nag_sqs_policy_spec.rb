require 'spec_helper'
require 'cfn-nag/cfn_nag_config'
require 'cfn-nag/cfn_nag'

describe CfnNag do
  before(:all) do
    CfnNagLogging.configure_logging(debug: false)
    @cfn_nag = CfnNag.new(config: CfnNagConfig.new)
  end

  context 'SQS Queue Policy with NotAction' do
    it 'flags a warning' do
      template_name = 'json/sqs_queue_policy/sqs_policy_with_not_action.json'

      expected_aggregate_results = [
        {
          filename: test_template_path(template_name),
          file_results: {
            # only increment this when Violation::FAILING (vs WARNING)
            failure_count: 0,
            violations: [
              SqsQueuePolicyNotActionRule.new.violation(%w[QueuePolicyWithNotAction QueuePolicyWithNotAction2], [20, 37])
            ]
          }
        }
      ]

      actual_aggregate_results =
        @cfn_nag.audit_aggregate_across_files(
          input_path: test_template_path(template_name)
        )
      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end
end
