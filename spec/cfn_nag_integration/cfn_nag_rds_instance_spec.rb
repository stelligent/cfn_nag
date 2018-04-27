require 'spec_helper'
require 'cfn-nag/cfn_nag'

describe CfnNag do
  before(:all) do
    CfnNag.configure_logging(debug: false)
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
                            message:
                            'RDS instance should not be publicly accessible',
                            logical_resource_ids: %w[PublicDB])
            ]
          }
        }
      ]

      actual_aggregate_results = @cfn_nag.audit_aggregate_across_files input_path: test_template_path(template_name)
      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end

  context 'one RDS instance with default credentials and no-echo is true' do
    it 'flags a violation' do
      template_name = 'json/rds_instance/rds_instance_no_echo_with_default_password.json'

      expected_aggregate_results = [
        {
          filename: test_template_path(template_name),
          file_results: {
            failure_count: 2,
            violations: [
              Violation.new(
                id: 'F23', type: Violation::FAILING_VIOLATION,
                message: 'RDS instance master user password must be Ref to NoEcho Parameter. Default credentials are not recommended',
                logical_resource_ids: %w[BadDb2]
              ),
              Violation.new(id: 'F22',
                            type: Violation::FAILING_VIOLATION,
                            message:
                            'RDS instance should not be publicly accessible',
                            logical_resource_ids: %w[BadDb2])
            ]
          }
        }
      ]

      actual_aggregate_results = @cfn_nag.audit_aggregate_across_files input_path: test_template_path(template_name)
      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end

  context 'RDS instances with non-encrypted credentials' do
    it 'flags a violation' do
      template_name =
        'json/rds_instance/rds_instances_with_public_credentials.json'

      expected_aggregate_results = [
        {
          filename: test_template_path(template_name),
          file_results: {
            failure_count: 4,
            violations: [
              Violation.new(
                id: 'F23', type: Violation::FAILING_VIOLATION,
                message: 'RDS instance master user password must be Ref to NoEcho Parameter. Default credentials are not recommended',
                logical_resource_ids: %w[BadDb1 BadDb2]
              ),
              Violation.new(
                id: 'F24', type: Violation::FAILING_VIOLATION,
                message: 'RDS instance master username must be Ref to NoEcho Parameter. Default credentials are not recommended',
                logical_resource_ids: %w[BadDb1 BadDb2]
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
