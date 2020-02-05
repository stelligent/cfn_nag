# frozen_string_literal: true

require 'spec_helper'
require 'cfn-nag/cfn_nag_config'
require 'cfn-nag/cfn_nag'

describe CfnNag do
  before(:all) do
    CfnNagLogging.configure_logging(debug: false)
    @cfn_nag = CfnNag.new(config: CfnNagConfig.new)
  end

  context 'when sg properties are missing', :foo do
    it 'flags a fatal violation' do
      template_name = 'json/security_group/sg_missing_properties.json'

      expected_aggregate_results = [
        {
          filename: test_template_path(template_name),
          file_results: {
            failure_count: 1,
            violations: [
              Violation.new(id: 'FATAL',
                            type: Violation::FAILING_VIOLATION,
                            message: "Basic CloudFormation syntax error:[#<Kwalify::ValidationError: [/Resources/sg] key 'Properties:' is required.>]",
                            logical_resource_ids: [])
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

  context 'when egress is empty' do
    it 'flags a violation' do
      template_name =
        'json/security_group/single_security_group_empty_ingress.json'

      expected_aggregate_results = [
        {
          filename: test_template_path(template_name),
          file_results: {
            failure_count: 1,
            violations: [
              Violation.new(
                id: 'F1000', type: Violation::FAILING_VIOLATION,
                message: 'Missing egress rule means all traffic is allowed outbound.  Make this explicit if it is desired configuration',
                logical_resource_ids: %w[sg],
                line_numbers: [4]
              )
            ]
          }
        }
      ]

      actual_aggregate_results = @cfn_nag.audit_aggregate_across_files input_path: test_template_path(template_name)
      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end

  context 'when inline ingress is open to world and two egress are missing' do
    it 'flags a violation' do
      template_name =
        'json/security_group/two_security_group_two_cidr_ingress.json'

      expected_aggregate_results = [
        {
          filename: test_template_path(template_name),
          file_results: {
            failure_count: 2,
            violations: [
              Violation.new(
                id: 'W9', type: Violation::WARNING,
                message: 'Security Groups found with ingress cidr that is not /32',
                logical_resource_ids: %w[sg2],
                line_numbers: [18]
              ),
              Violation.new(
                id: 'W2', type: Violation::WARNING,
                message: 'Security Groups found with cidr open to world on ingress.  This should never be true on instance.  Permissible on ELB',
                logical_resource_ids: %w[sg2],
                line_numbers: [18]
              ),
              Violation.new(
                id: 'W27', type: Violation::WARNING,
                message: 'Security Groups found ingress with port range instead of just a single port',
                logical_resource_ids: %w[sg sg2],
                line_numbers: [4, 18]
              ),
              Violation.new(
                id: 'F1000', type: Violation::FAILING_VIOLATION,
                message: 'Missing egress rule means all traffic is allowed outbound.  Make this explicit if it is desired configuration',
                logical_resource_ids: %w[sg sg2],
                line_numbers: [4, 18]
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

  context 'when has multiple inline egress rules' do
    it 'passes validation' do
      template_name = 'json/security_group/multiple_inline_egress.json'

      expected_aggregate_results = [
        {
          filename: test_template_path(template_name),
          file_results: {
            failure_count: 0,
            violations: []
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

  context 'two security group ingress standalone with non /32 cidr (array and non-array)' do
    it 'flags a warning' do
      template_name = 'json/security_group/non_32_cidr_standalone_ingress.json'

      expected_aggregate_results = [
        {
          filename: test_template_path(template_name),
          file_results: {
            failure_count: 0,
            violations: [
              Violation.new(
                id: 'W9', type: Violation::WARNING,
                message:
                'Security Groups found with ingress cidr that is not /32',
                logical_resource_ids: %w[sg],
                line_numbers: [9]
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

  context 'two security groups with non /32 cidr (array and non-array)' do
    it 'flags a warning' do
      template_name = 'json/security_group/non_32_cidr.json'

      expected_aggregate_results = [
        {
          filename: test_template_path(template_name),
          file_results: {
            failure_count: 0,
            violations: [
              Violation.new(
                id: 'W9', type: Violation::WARNING,
                message:
                'Security Groups found with ingress cidr that is not /32',
                logical_resource_ids: %w[sg sg2],
                line_numbers: [9, 30]
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
