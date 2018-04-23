require 'spec_helper'
require 'cfn-nag/cfn_nag'

describe CfnNag do
  before(:all) do
    CfnNag.configure_logging(debug: false)
    @cfn_nag = CfnNag.new
  end

  context 'EBS volumes without encryption', :ebs do
    it 'flags a violation' do
      template_name = 'json/ec2_volume/two_ebs_volumes_with_no_encryption.json'

      expected_aggregate_results = [
        {
          filename: test_template_path(template_name),
          file_results: {
            failure_count: 2,
            violations: [
              Violation.new(
                id: 'F1', type: Violation::FAILING_VIOLATION,
                message:
                'EBS volume should have server-side encryption enabled',
                logical_resource_ids: %w[NewVolume1 NewVolume2]
              )
            ]
          }
        }
      ]

      actual_aggregate_results = @cfn_nag.audit_aggregate_across_files(
        input_path: test_template_path(template_name)
      )
      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end

  context 'EBS volumes with encryption', :ebs do
    it 'flags a violation' do
      template_name = 'json/ec2_volume/ebs_volume_with_encryption.json'

      expected_aggregate_results = [
        {
          filename: test_template_path(template_name),
          file_results: {
            failure_count: 0,
            violations: []
          }
        }
      ]

      actual_aggregate_results = @cfn_nag.audit_aggregate_across_files(
        input_path: test_template_path(template_name)
      )
      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end
end
