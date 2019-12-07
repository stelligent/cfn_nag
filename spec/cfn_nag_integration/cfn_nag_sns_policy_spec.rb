require 'spec_helper'
require 'cfn-nag/cfn_nag_config'
require 'cfn-nag/cfn_nag'

describe CfnNag do
  before(:all) do
    CfnNagLogging.configure_logging(debug: false)
    @cfn_nag = CfnNag.new(config: CfnNagConfig.new)
  end

  context 'sns with wildcard principal', :sns do
    it 'flags a violation' do
      template_name =
        'json/sns_topic_policy/sns_topic_with_wildcard_principal.json'

      expected_aggregate_results = [
        {
          filename: test_template_path(template_name),
          file_results: {
            # only increment this when Violation::FAILING (vs WARNING)
            failure_count: 4,
            violations: [
              Violation.new(
                id: 'F18', type: Violation::FAILING_VIOLATION,
                message: 'SNS topic policy should not allow * principal',
                logical_resource_ids: %w[mysnspolicy0 mysnspolicy1
                                         mysnspolicy2 mysnspolicy3],
                line_numbers: [11, 29, 55, 85]
              )
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
