require 'spec_helper'
require 'cfn-nag/cfn_nag'

describe CfnNag do
  before(:all) do
    CfnNag::configure_logging({debug: false})
    @cfn_nag = CfnNag.new
  end

  context 'one RDS instance with public access' do
    it 'flags a violation' do
      template_name = 'json/rds_instance/rds_instance_publicly_accessible.json'

      expected_aggregate_results = [
        {
          filename: test_template_path(template_name),
          file_results: {
            failure_count: 1,
            violations: [
              Violation.new(id: 'F22',
                            type: Violation::FAILING_VIOLATION,
                            message: 'RDS instance should not be publicly accessible',
                            logical_resource_ids: %w(PublicDB))
            ]
          }
        }
      ]

      actual_aggregate_results = @cfn_nag.audit_aggregate_across_files(input_path: test_template_path(template_name))
      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end
end



