require 'spec_helper'
require 'cfn-nag/cfn_nag_config'
require 'cfn-nag/cfn_nag'
require 'cfn-nag/cfn_nag_logging'

describe CfnNag do
  before(:all) do
    CfnNagLogging.configure_logging(debug: false)
    @cfn_nag = CfnNag.new(config: CfnNagConfig.new)
  end

  context 'when authentication metadata is specified' do
    it 'flags a warning' do
      template_name = 'json/ec2_instance/cfn_authentication.json'

      expected_aggregate_results = [
        {
          filename: test_template_path(template_name),
          file_results: {
            failure_count: 0,
            violations: [
              Violation.new(
                id: 'W1', type: Violation::WARNING,
                message: 'Specifying credentials in the template itself is probably not the safest thing',
                logical_resource_ids: %w[EC2I4LBA1],
                line_numbers: [11]
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
