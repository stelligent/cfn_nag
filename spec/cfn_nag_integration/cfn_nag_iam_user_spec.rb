require 'spec_helper'
require 'cfn-nag/cfn_nag_config'
require 'cfn-nag/cfn_nag'

describe CfnNag do
  before(:all) do
    CfnNagLogging.configure_logging(debug: false)
    @cfn_nag = CfnNag.new(config: CfnNagConfig.new)
  end

  context 'iam user has no group membership', :sns do
    it 'flags a violation' do
      template_name = 'json/iam_user/iam_user_with_no_group.json'

      expected_aggregate_results = [
        {
          filename: test_template_path(template_name),
          file_results: {
            # only increment this when Violation::FAILING (vs WARNING)
            failure_count: 1,
            violations: [
              Violation.new(id: 'F2000',
                            type: Violation::FAILING_VIOLATION,
                            message: 'User is not assigned to a group',
                            logical_resource_ids: %w[myuser2],
                            line_numbers: [4])
            ]
          }
        }
      ]

      actual_aggregate_results = @cfn_nag.audit_aggregate_across_files input_path: test_template_path(template_name)
      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end
end
