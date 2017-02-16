require 'spec_helper'
require 'cfn_nag'


describe CfnNag do
  before(:all) do
    CfnNag::configure_logging({debug: false})
    @cfn_nag = CfnNag.new
  end

  def test_template(template_name)
    File.new(File.join(__dir__, 'test_templates', template_name))
  end

  describe '#dump_rules' do
    it 'should emit all rules to stdout' do
      @cfn_nag.dump_rules
    end
  end

  context 'when illegal json is input' do
    it 'fails fast' do
      template_name = 'rubbish.json'
      failure_count = @cfn_nag.audit(input_json_path: test_template(template_name))
      expect(failure_count).to eq 1
    end
  end

  context 'when resource are missing' do
    it 'flags a violation' do
      template_name = 'no_resources.json'
      failure_count = @cfn_nag.audit(input_json_path: test_template(template_name))
      expect(failure_count).to eq 1
    end
  end
  context 'when sg properties are missing', :foo do

    it 'flags a violation' do
      template_name = 'sg_missing_properties.json'
      failure_count = @cfn_nag.audit(input_json_path: test_template(template_name))
      expect(failure_count).to eq 1
    end
  end

  context 'when egress is empty' do

    it 'flags a violation' do
      template_name = 'single_security_group_empty_ingress.json'

      failure_count = @cfn_nag.audit(input_json_path: test_template(template_name))
      expect(failure_count).to eq 1
    end
  end

  context 'when egress is empty' do

    it 'flags a violation' do
      template_name = 'single_security_group_empty_ingress.json'

      failure_count = @cfn_nag.audit(input_json_path: test_template(template_name))
      expect(failure_count).to eq 1
    end
  end

  context 'when inline ingress is open to world is empty and two egress are missing' do
    it 'flags a violation' do
      template_name = 'two_security_group_two_cidr_ingress.json'

      failure_count = @cfn_nag.audit(input_json_path: test_template(template_name))
      expect(failure_count).to eq 2
    end
  end

  context 'when has multiple inline egress rules' do

    it 'passes validation' do
      template_name = 'multiple_inline_egress.json'

      failure_count = @cfn_nag.audit(input_json_path: test_template(template_name))
      expect(failure_count).to eq 0
    end
  end

  context 'when inline iam user has no group membership' do

    it 'flags a violation' do
      template_name = 'iam_user_with_no_group.json'

      failure_count = @cfn_nag.audit(input_json_path: test_template(template_name))
      expect(failure_count).to eq 1
    end
  end

  context 'when authentication metadata is specified' do

    it 'flags a warning' do
      template_name = 'cfn_authentication.json'

      expected_aggregate_results = [
        {
          filename: File.join(__dir__, 'test_templates/cfn_authentication.json'),
          file_results: {
            failure_count: 0,
            violations: [
              Violation.new(type: Violation::WARNING,
                            message: 'Specifying credentials in the template itself is probably not the safest thing',
                            logical_resource_ids: %w(EC2I4LBA1),
                            violating_code: nil)
            ]
          }
        }
      ]

      failure_count = @cfn_nag.audit(input_json_path: test_template(template_name))
      expect(failure_count).to eq 0

      actual_aggregate_results = @cfn_nag.audit_results(input_json_path: test_template(template_name))
      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end

  context 'two load balancers without access logging enabled' do

    it 'flags a warning' do
      template_name = 'two_load_balancers_with_no_logging.json'

      expected_aggregate_results = [
          {
              filename: File.join(__dir__, 'test_templates/two_load_balancers_with_no_logging.json'),
              file_results: {
                  failure_count: 0,
                  violations: [
                      Violation.new(type: Violation::WARNING,
                                    message: 'Elastic Load Balancer should have access logging configured',
                                    logical_resource_ids: %w(elb1),
                                    violating_code: nil),
                      Violation.new(type: Violation::WARNING,
                                    message: 'Elastic Load Balancer should have access logging enabled',
                                    logical_resource_ids: %w(elb2),
                                    violating_code: nil),
                      Violation.new(type: Violation::WARNING,
                                    message: 'It appears that the S3 Bucket Policy allows s3:PutObject without server-side encryption',
                                    logical_resource_ids: %w(S3BucketPolicy),
                                    violating_code: nil)
                  ]
              }
          }
      ]

      failure_count = @cfn_nag.audit(input_json_path: test_template(template_name))
      expect(failure_count).to eq 0

      actual_aggregate_results = @cfn_nag.audit_results(input_json_path: test_template(template_name))
      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end

  context 'two buckets with insecure ACL - PublicRead and PublicReadWrite' do

    it 'flags a warning and a violation' do
      template_name = 'buckets_with_insecure_acl.json'

      expected_aggregate_results = [
          {
              filename: File.join(__dir__, 'test_templates/buckets_with_insecure_acl.json'),
              file_results: {
                  failure_count: 1,
                  violations: [
                      Violation.new(type: Violation::WARNING,
                                    message: 'S3 Bucket likely should not have a public read acl',
                                    logical_resource_ids: %w(S3BucketRead),
                                    violating_code: nil),
                      Violation.new(type: Violation::FAILING_VIOLATION,
                                    message: 'S3 Bucket should not have a public read-write acl',
                                    logical_resource_ids: %w(S3BucketReadWrite),
                                    violating_code: nil)
                  ]
              }
          }
      ]

      failure_count = @cfn_nag.audit(input_json_path: test_template(template_name))
      expect(failure_count).to eq 1

      actual_aggregate_results = @cfn_nag.audit_results(input_json_path: test_template(template_name))
      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end


  context 'cloudfront distro without logging' do

    it 'flags a warning' do
      template_name = 'cloudfront_distribution_without_logging.json'

      expected_aggregate_results = [
          {
              filename: File.join(__dir__, 'test_templates/cloudfront_distribution_without_logging.json'),
              file_results: {
                  failure_count: 0,
                  violations: [
                      Violation.new(type: Violation::WARNING,
                                    message: 'CloudFront Distribution should enable access logging',
                                    logical_resource_ids: %w(rDistribution2),
                                    violating_code: nil)
                  ]
              }
          }
      ]

      failure_count = @cfn_nag.audit(input_json_path: test_template(template_name))
      expect(failure_count).to eq 0

      actual_aggregate_results = @cfn_nag.audit_results(input_json_path: test_template(template_name))
      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end


  context 'lambda permission with some out of the ordinary items' do

    it 'flags a warning' do
      template_name = 'lambda_with_wildcard_principal_and_non_invoke_function_permission.json'

      expected_aggregate_results = [
          {
              filename: File.join(__dir__, 'test_templates/lambda_with_wildcard_principal_and_non_invoke_function_permission.json'),
              file_results: {
                  failure_count: 1,
                  violations: [
                      Violation.new(type: Violation::WARNING,
                                    message: 'Lambda permission beside InvokeFunction might not be what you want?  Not sure!?',
                                    logical_resource_ids: %w(lambdaPermission),
                                    violating_code: nil),
                      Violation.new(type: Violation::FAILING_VIOLATION,
                                    message: 'Lambda permission principal should not be wildcard',
                                    logical_resource_ids: %w(lambdaPermission),
                                    violating_code: nil)
                  ]
              }
          }
      ]

      failure_count = @cfn_nag.audit(input_json_path: test_template(template_name))
      expect(failure_count).to eq 1

      actual_aggregate_results = @cfn_nag.audit_results(input_json_path: test_template(template_name))
      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end

  context 'sqs with wildcards', :sqs do

    it 'flags a violation' do
      template_name = 'sqs_queue_with_wildcards.json'

      expected_aggregate_results = [
          {
              filename: File.join(__dir__, 'test_templates/sqs_queue_with_wildcards.json'),
              file_results: {
                  failure_count: 2,
                  violations: [
                      Violation.new(type: Violation::FAILING_VIOLATION,
                                    message: 'SQS Queue policy should not allow * action',
                                    logical_resource_ids: %w(mysqspolicy),
                                    violating_code: nil),
                      Violation.new(type: Violation::FAILING_VIOLATION,
                                    message: 'SQS Queue policy should not allow * principal',
                                    logical_resource_ids: %w(mysqspolicy2),
                                    violating_code: nil)
                  ]
              }
          }
      ]

      failure_count = @cfn_nag.audit(input_json_path: test_template(template_name))
      #expect(failure_count).to eq 2

      actual_aggregate_results = @cfn_nag.audit_results(input_json_path: test_template(template_name))
      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end

  context 'sns with wildcards' do

    it 'flags a violation' do
      template_name = 'sns_topic_with_wildcard_principal.json'

      expected_aggregate_results = [
          {
              filename: File.join(__dir__, 'test_templates/sns_topic_with_wildcard_principal.json'),
              file_results: {
                  failure_count: 4,
                  violations: [
                      Violation.new(type: Violation::FAILING_VIOLATION,
                                    message: 'SNS topic policy should not allow * principal',
                                    logical_resource_ids: %w(mysnspolicy0 mysnspolicy1),
                                    violating_code: nil),
                      Violation.new(type: Violation::FAILING_VIOLATION,
                                    message: 'SNS topic policy should not allow * AWS principal',
                                    logical_resource_ids: %w(mysnspolicy2 mysnspolicy3),
                                    violating_code: nil)
                  ]
              }
          }
      ]

      failure_count = @cfn_nag.audit(input_json_path: test_template(template_name))
      expect(failure_count).to eq 4

      actual_aggregate_results = @cfn_nag.audit_results(input_json_path: test_template(template_name))
      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end


  context 's3 with wildcards', :s3 do

    it 'flags a violation' do
      template_name = 's3_bucket_with_wildcards.json'

      expected_aggregate_results = [
          {
              filename: File.join(__dir__, 'test_templates/s3_bucket_with_wildcards.json'),
              file_results: {
                  failure_count: 3,
                  violations: [
                      Violation.new(type: Violation::FAILING_VIOLATION,
                                    message: 'S3 Bucket policy should not allow * action',
                                    logical_resource_ids: %w(S3BucketPolicy S3BucketPolicy2),
                                    violating_code: nil),
                      Violation.new(type: Violation::FAILING_VIOLATION,
                                    message: 'S3 Bucket policy should not allow * AWS principal',
                                    logical_resource_ids: %w(S3BucketPolicy2),
                                    violating_code: nil),
                      Violation.new(type: Violation::WARNING,
                                    message: 'It appears that the S3 Bucket Policy allows s3:PutObject without server-side encryption',
                                    logical_resource_ids: %w(S3BucketPolicy S3BucketPolicy2),
                                    violating_code: nil)
                  ]
              }
          }
      ]

      failure_count = @cfn_nag.audit(input_json_path: test_template(template_name))
      #expect(failure_count).to eq 4

      actual_aggregate_results = @cfn_nag.audit_results(input_json_path: test_template(template_name))
      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end

  context 'igw rule in custom rule dir', :rule_directory do

    it 'flags a violation' do
      expected_aggregate_results = [
        {
          filename: File.join(__dir__, 'test_templates/igw.json'),
          file_results: {
            failure_count: 1,
            violations: [
              Violation.new(type: Violation::FAILING_VIOLATION,
                            message: 'Internet Gateways are not allowed',
                            logical_resource_ids: ['igw'] )
            ]
          }
        }
      ]

      template_name = 'igw.json'

      failure_count = @cfn_nag.audit(input_json_path: test_template(template_name),
                                     rule_directories: [File.join(__dir__, 'other_json_rules')])
      expect(failure_count).to eq 1

      actual_aggregate_results = @cfn_nag.audit_results(input_json_path: test_template(template_name),
                                                        rule_directories: [File.join(__dir__, 'other_json_rules')])
      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end

  context 'igw rule not there', :rule_directory do

    it 'flags a violation' do
      template_name = 'igw.json'

      failure_count = @cfn_nag.audit(input_json_path: test_template(template_name))
      expect(failure_count).to eq 0

    end
  end



end
