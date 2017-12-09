require 'spec_helper'
require 'cfn-nag/cfn_nag'
require 'cfn-nag/profile_loader'

describe CfnNag do
  before(:each) do
    CfnNag.configure_logging(debug: false)
    @cfn_nag = CfnNag.new
  end

  describe '#audit_aggregate_across_files_and_render_results' do
    context 'json output' do
      it 'renders json results' do
        @cfn_nag.audit_aggregate_across_files_and_render_results(input_path: test_template_path('json/s3_bucket_policy/s3_bucket_with_wildcards.json'),
                                                                 output_format: 'json')
        # measuring stdout assertion here is going to be a pain and maybe fragile as rules are added
        # just make sure the rendering doesn't blow i guess
      end
    end

    context 'txt output' do
      it 'renders json results' do
        @cfn_nag.audit_aggregate_across_files_and_render_results(input_path: test_template_path('json/s3_bucket_policy/s3_bucket_with_wildcards.json'),
                                                                 output_format: 'txt')
        # measuring stdout assertion here is going to be a pain and maybe fragile as rules are added
        # just make sure the rendering doesn't blow i guess
      end
    end
  end

  describe '#audit_aggregate_across_files' do
    context 'when illegal json is input' do
      it 'fails fast' do
        template_name = 'json/structural/rubbish.json'

        # JSON.load and YAML.load have different behaviors here....
        # JSON.load blows up and YAML.load deals with the string...
        # either way I guess it's cool to just wait until we get to the no Resources bit
        expected_aggregate_results = [
          {
            filename: test_template_path(template_name),
            file_results: {
              failure_count: 1,
              violations: [
                Violation.new(id: 'FATAL',
                              type: Violation::FAILING_VIOLATION,
                              message: 'Illegal cfn - no Resources',
                              logical_resource_ids: nil)
              ]
            }
          }
        ]

        actual_aggregate_results = @cfn_nag.audit_aggregate_across_files(input_path: test_template_path(template_name))
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
                              logical_resource_ids: nil)
              ]
            }
          }
        ]

        actual_aggregate_results = @cfn_nag.audit_aggregate_across_files(input_path: test_template_path(template_name))
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
                Violation.new(id: 'F16',
                              type: Violation::FAILING_VIOLATION,
                              message: 'S3 Bucket policy should not allow * principal',
                              logical_resource_ids: %w(S3BucketPolicy2))

              ]
            }
          }
        ]

        rule_registry = RuleRegistry.new

        (1..100).each do |num|
          rule_registry.definition(id: "F#{num}",
                                   type: Violation::FAILING_VIOLATION,
                                   message: "fakeo#{num}")
        end

        @cfn_nag = CfnNag.new(profile_definition: "F16\n")

        actual_aggregate_results = @cfn_nag.audit_aggregate_across_files(input_path: test_template_path(template_name))
        expect(actual_aggregate_results).to eq expected_aggregate_results
      end
    end
  end

  context 'when template has suppression metadata' do
    it 'ignores rules on suppressed resources' do
      template_name = 'yaml/security_group/sg_with_suppression.yml'
      @cfn_nag = CfnNag.new print_suppression: true

      expected_aggregate_results = [
        {
          filename: test_template_path(template_name),
          file_results: {
            failure_count: 1,
            violations: [
              Violation.new(id: 'W9',
                            type: Violation::WARNING,
                            message: 'Security Groups found with ingress cidr that is not /32',
                            logical_resource_ids: %w(sgOpenIngress)),
              Violation.new(id: 'W2',
                            type: Violation::WARNING,
                            message: 'Security Groups found with cidr open to world on ingress.  This should never be true on instance.  Permissible on ELB',
                            logical_resource_ids: %w(sgOpenIngress)),
              Violation.new(id: 'F1000',
                            type: Violation::FAILING_VIOLATION,
                            message: 'Missing egress rule means all traffic is allowed outbound.  Make this explicit if it is desired configuration',
                            logical_resource_ids: %w(sgOpenIngress))
            ]
          }
        }
      ]

      expected_stderr = <<END
Suppressing W9 on sgOpenIngress2 for reason: Trying to prove a point
Suppressing W2 on sgOpenIngress2 for reason: This security group is attached to internet-facing ELB
Suppressing F1000 on sgOpenIngress2 for reason: To enable sensitive data exfiltration ;)
END
      actual_aggregate_results = nil
      expect {
        actual_aggregate_results = @cfn_nag.audit_aggregate_across_files(input_path: test_template_path(template_name))
      }.to output(expected_stderr).to_stderr_from_any_process

      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end

  context 'when template has suppression metadata and suppression is disallowed' do
    it 'ignores rules on suppressed resources' do
      @cfn_nag = CfnNag.new(allow_suppression: false)

      template_name = 'yaml/security_group/sg_with_suppression.yml'

      expected_aggregate_results = [
        {
          filename: test_template_path(template_name),
          file_results: {
            failure_count: 2,
            violations: [
              Violation.new(id: 'W9',
                            type: Violation::WARNING,
                            message: 'Security Groups found with ingress cidr that is not /32',
                            logical_resource_ids: %w(sgOpenIngress sgOpenIngress2)),
              Violation.new(id: 'W2',
                            type: Violation::WARNING,
                            message: 'Security Groups found with cidr open to world on ingress.  This should never be true on instance.  Permissible on ELB',
                            logical_resource_ids: %w(sgOpenIngress sgOpenIngress2)),
              Violation.new(id: 'F1000',
                            type: Violation::FAILING_VIOLATION,
                            message: 'Missing egress rule means all traffic is allowed outbound.  Make this explicit if it is desired configuration',
                            logical_resource_ids: %w(sgOpenIngress sgOpenIngress2))
            ]
          }
        }
      ]
      actual_aggregate_results = @cfn_nag.audit_aggregate_across_files(input_path: test_template_path(template_name))

      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end

  context 'when template has mangled suppression metadata' do
    it 'raises an error' do
      template_name = 'yaml/security_group/sg_with_mangled_metadata.yml'

      expect do
        _ = @cfn_nag.audit_aggregate_across_files(input_path: test_template_path(template_name))
      end.to output('sgOpenIngress2 has missing cfn_nag suppression rule id: [{"reason"=>"This security group is attached to internet-facing ELB"}]' + "\n").to_stderr_from_any_process
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
              Violation.new(id: 'FATAL',
                            type: Violation::FAILING_VIOLATION,
                            message: '(<unknown>): mapping values are not allowed in this context at line 3 column 15'),
            ]
          }
        }
      ]
      actual_aggregate_results = @cfn_nag.audit_aggregate_across_files(input_path: test_template_path(template_name))

      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end
end
