# frozen_string_literal: true

require 'spec_helper'
require 'cfn-nag/cfn_nag_config'
require 'cfn-nag/cfn_nag'
require 'cfn-nag/cfn_nag_logging'
require 'cfn-nag/profile_loader'

describe CfnNag do
  before(:each) do
    CfnNagLogging.configure_logging(debug: false)
    @cfn_nag = CfnNag.new(config: CfnNagConfig.new)
  end

  describe '#audit_aggregate_across_files_and_render_results' do
    context 'json output' do
      it 'renders json results' do
        expect do
          @cfn_nag.audit_aggregate_across_files_and_render_results(
            input_path: test_template_path('json/s3_bucket_policy/s3_bucket_with_wildcards.json'),
            output_format: 'json'
          )
        end.to output(/"type": "FAIL"/).to_stdout
      end
    end

    context 'colortxt output' do
      # \e[0;31;49m is the ANSI escape sequence for red
      it 'colorizes failures as red' do
        expect do
          @cfn_nag.audit_aggregate_across_files_and_render_results(
            input_path: test_template_path('json/s3_bucket_policy/s3_bucket_with_wildcards.json'),
            output_format: 'colortxt'
          )
        end.to output(/\e\[31m/).to_stdout
      end

      # \e[0;33;49m is the ANSI escape sequence for yellow
      it 'colorizes warnings as yellow' do
        expect do
          @cfn_nag.audit_aggregate_across_files_and_render_results(
            input_path: test_template_path('yaml/security_group/sg_with_suppression.yml'),
            output_format: 'colortxt'
          )
        end.to output(/\e\[33m/).to_stdout
      end
    end

    context 'txt output' do
      it 'renders text results' do
        expect do
          @cfn_nag.audit_aggregate_across_files_and_render_results(
            input_path: test_template_path('json/s3_bucket_policy/s3_bucket_with_wildcards.json'),
            output_format: 'txt'
          )
        end.to output(/\| FAIL F15/).to_stdout
      end

      # \e[0;31;49m is the ANSI escape sequence for red
      it 'Does not colorize failures as red' do
        expect do
          @cfn_nag.audit_aggregate_across_files_and_render_results(
            input_path: test_template_path('json/s3_bucket_policy/s3_bucket_with_wildcards.json'),
            output_format: 'txt'
          )
        end.to_not output(/\e\[31m/).to_stdout
      end

      # \e[0;33;49m is the ANSI escape sequence for yellow
      it 'Does not colorize warnings as yellow' do
        expect do
          @cfn_nag.audit_aggregate_across_files_and_render_results(
            input_path: test_template_path('yaml/security_group/sg_with_suppression.yml'),
            output_format: 'txt'
          )
        end.to_not output(/\e\[33m/).to_stdout
      end
    end
  end

  describe '#audit_aggregate_across_files' do
    context 'when illegal json is input' do
      it 'fails fast' do
        template_name = 'json/structural/rubbish.json'

        # JSON.load and YAML.load have different behaviors here....
        # JSON.load blows up and YAML.load deals with the string...
        # either way I guess it's cool to just wait until we get to the
        # no Resources bit
        expected_aggregate_results = [
          {
            filename: test_template_path(template_name),
            file_results: {
              failure_count: 1,
              violations: [
                Violation.new(id: 'FATAL',
                              type: Violation::FAILING_VIOLATION,
                              message: 'Illegal cfn - no Resources',
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

    context 'when resource are missing' do
      it 'flags a violation' do
        template_name = 'json/structural/no_resources.json'

        expected_aggregate_results = [
          {
            filename: test_template_path(template_name),
            file_results: {
              failure_count: 1,
              violations: [
                Violation.new(id: 'FATAL',
                              type: Violation::FAILING_VIOLATION,
                              message: 'Illegal cfn - no Resources',
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

    context 'template with multiple violation' do
      it 'only flags violations in profile' do
        template_name = 'json/s3_bucket_policy/s3_bucket_with_wildcards.json'

        expected_aggregate_results = [
          {
            filename: test_template_path(template_name),
            file_results: {
              failure_count: 1,
              violations: [
                Violation.new(
                  id: 'F16', type: Violation::FAILING_VIOLATION,
                  message: 'S3 Bucket policy should not allow * principal',
                  logical_resource_ids: %w[S3BucketPolicy2],
                  line_numbers: [86]
                )
              ]
            }
          }
        ]

        rule_registry = RuleRegistry.new

        (1..100).each do |num|
          rule_klass = Object.const_set("RuleF#{num}", Class.new)
          rule_klass.class_eval %Q{
            def rule_text
              "fakeo#{num}"
            end

            def rule_type
              Violation::FAILING_VIOLATION
            end

            def rule_id
              "F#{num}"
            end
          }

          rule_registry.definition(rule_klass)
        end

        @cfn_nag = CfnNag.new(config: CfnNagConfig.new(profile_definition: "F16\n"))

        actual_aggregate_results =
          @cfn_nag.audit_aggregate_across_files(
            input_path: test_template_path(template_name)
          )
        expect(actual_aggregate_results).to eq expected_aggregate_results
      end
    end
  end

  context 'when template has suppression metadata' do
    it 'ignores rules on suppressed resources' do
      template_name = 'yaml/security_group/sg_with_suppression.yml'
      @cfn_nag = CfnNag.new(config: CfnNagConfig.new(print_suppression: true))

      expected_aggregate_results = [
        {
          filename: test_template_path(template_name),
          file_results: {
            failure_count: 1,
            violations: [
              Violation.new(
                id: 'W9', type: Violation::WARNING,
                message: 'Security Groups found with ingress cidr that is not /32',
                logical_resource_ids: %w[sgOpenIngress],
                line_numbers: [4]
              ),
              Violation.new(
                id: 'W2', type: Violation::WARNING,
                message: 'Security Groups found with cidr open to world on ingress.  This should never be true on instance.  Permissible on ELB',
                logical_resource_ids: %w[sgOpenIngress],
                line_numbers: [4]
              ),
              Violation.new(
                id: 'F1000', type: Violation::FAILING_VIOLATION,
                message: 'Missing egress rule means all traffic is allowed outbound.  Make this explicit if it is desired configuration',
                logical_resource_ids: %w[sgOpenIngress],
                line_numbers: [4]
              )
            ]
          }
        }
      ]

      expected_stderr = <<EXPECTEDSTDERR
Suppressing W9 on sgOpenIngress2 for reason: Trying to prove a point
Suppressing W2 on sgOpenIngress2 for reason: This security group is attached to internet-facing ELB
Suppressing F1000 on sgOpenIngress2 for reason: To enable sensitive data exfiltration ;)
EXPECTEDSTDERR
      actual_aggregate_results = nil
      expect do
        actual_aggregate_results =
          @cfn_nag.audit_aggregate_across_files(
            input_path: test_template_path(template_name)
          )
      end.to output(expected_stderr).to_stderr_from_any_process

      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end

  context 'when template has suppression metadata and suppression is disallowed' do
    it 'ignores rules on suppressed resources' do
      @cfn_nag = CfnNag.new(config: CfnNagConfig.new(allow_suppression: false))

      template_name = 'yaml/security_group/sg_with_suppression.yml'

      expected_aggregate_results = [
        {
          filename: test_template_path(template_name),
          file_results: {
            failure_count: 2,
            violations: [
              Violation.new(
                id: 'W9', type: Violation::WARNING,
                message: 'Security Groups found with ingress cidr that is not /32',
                logical_resource_ids: %w[sgOpenIngress sgOpenIngress2],
                line_numbers: [4, 21]
              ),
              Violation.new(
                id: 'W2', type: Violation::WARNING,
                message: 'Security Groups found with cidr open to world on ingress.  This should never be true on instance.  Permissible on ELB',
                logical_resource_ids: %w[sgOpenIngress sgOpenIngress2],
                line_numbers: [4, 21]
              ),
              Violation.new(
                id: 'F1000', type: Violation::FAILING_VIOLATION,
                message: 'Missing egress rule means all traffic is allowed outbound.  Make this explicit if it is desired configuration',
                logical_resource_ids: %w[sgOpenIngress sgOpenIngress2],
                line_numbers: [4, 21]
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

  context 'when template has mangled suppression metadata' do
    it 'raises an error' do
      template_name = 'yaml/security_group/sg_with_mangled_metadata.yml'

      expect do
        _ = @cfn_nag.audit_aggregate_across_files(
          input_path: test_template_path(template_name)
        )
      end.to output('sgOpenIngress2 has missing cfn_nag suppression rule id: [{"reason"=>"This security group is attached to internet-facing ELB"}]' + "\n")
        .to_stderr_from_any_process
    end
  end

  context 'when template has vulgar syntax error' do
    it 'returns a fatal violation' do
      template_name = 'yaml/vulgar_bad_syntax.yml'

      expected_aggregate_results = [
        {
          filename: test_template_path(template_name),
          file_results: {
            failure_count: 1,
            violations: [
              Violation.new(
                id: 'FATAL',
                type: Violation::FAILING_VIOLATION,
                message: '(<unknown>): mapping values are not allowed in this context at line 3 column 15'
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
