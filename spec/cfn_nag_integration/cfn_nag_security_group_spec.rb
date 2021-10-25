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
              Violation.fatal_violation("Basic CloudFormation syntax error:[#<Kwalify::ValidationError: [/Resources/sg] key 'Properties:' is required.>]")
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
              SecurityGroupMissingEgressRule.new.violation(%w[sg], [4])
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
              SecurityGroupIngressCidrNon32Rule.new.violation(%w[sg2], [18]),
              SecurityGroupIngressOpenToWorldRule.new.violation(%w[sg2], [18]),
              SecurityGroupIngressPortRangeRule.new.violation(%w[sg sg2], [4, 18]),
              SecurityGroupMissingEgressRule.new.violation(%w[sg sg2], [4, 18])
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
              SecurityGroupIngressCidrNon32Rule.new.violation(%w[sg], [9])
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
              SecurityGroupIngressCidrNon32Rule.new.violation(%w[sg sg2], [9, 30])
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
