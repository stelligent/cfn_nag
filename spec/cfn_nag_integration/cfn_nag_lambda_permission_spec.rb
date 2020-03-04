require 'spec_helper'
require 'cfn-nag/cfn_nag_config'
require 'cfn-nag/cfn_nag'

describe CfnNag do
  before(:all) do
    CfnNagLogging.configure_logging(debug: false)
    @cfn_nag = CfnNag.new(config: CfnNagConfig.new)
  end

  context 'lambda permission with some out of the ordinary items', :lambda do
    it 'flags a warning' do
      template_name = 'json/lambda_permission/lambda_with_wildcard_principal_and_non_invoke_function_permission.json'

      expected_aggregate_results = [
        {
          filename: test_template_path(template_name),
          file_results: {
            failure_count: 3,
            violations: [
              Violation.new(id: 'F38',
                            type: Violation::FAILING_VIOLATION,
                            message: 'IAM role should not allow * resource with PassRole action on its permissions policy',
                            logical_resource_ids: %w[LambdaExecutionRole],
                            line_numbers: [49]),
              Violation.new(id: 'F3',
                            type: Violation::FAILING_VIOLATION,
                            message: 'IAM role should not allow * action on its permissions policy',
                            logical_resource_ids: %w[LambdaExecutionRole],
                            line_numbers: [49]),
              Violation.new(id: 'W11',
                            type: Violation::WARNING,
                            message: 'IAM role should not allow * resource on its permissions policy',
                            logical_resource_ids: %w[LambdaExecutionRole],
                            line_numbers: [49]),
              Violation.new(id: 'F13',
                            type: Violation::FAILING_VIOLATION,
                            message: 'Lambda permission principal should not be wildcard',
                            logical_resource_ids: %w[lambdaPermission],
                            line_numbers: [23])
            ]
          }
        }
      ]

      actual_aggregate_results = @cfn_nag.audit_aggregate_across_files input_path: test_template_path(template_name)
      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end

  # the heavy lifting for dealing with globals is down in cfn-model.  just make sure we've got a good version
  # of the parser that doesn't blow up
  context 'serverless function with globals', :lambda do
    it 'parses properly' do
      template_name = 'yaml/sam/globals.yml'
      actual_aggregate_results = @cfn_nag.audit_aggregate_across_files input_path: test_template_path(template_name)
      expect(actual_aggregate_results[0][:file_results][:failure_count]).to eq 0
    end

    it 'makes globals available as a top-level hash' do
      template_name = 'yaml/sam/globals.yml'
      cfn_model = CfnParser.new.parse read_test_template(template_name)
      globals = cfn_model.globals

      expect(globals).to_not be_nil
      expect(globals['Function'].timeout).to eq 30
    end
  end

  context 'serverless function with implicit API', :lambda do
    it 'parses properly' do
      template_name = 'yaml/sam/serverless_rest_api_with_basepathmapping.yml'
      actual_aggregate_results = @cfn_nag.audit_aggregate_across_files input_path: test_template_path(template_name)
      expect(actual_aggregate_results[0][:file_results][:failure_count]).to eq 2
      violations = actual_aggregate_results[0][:file_results][:violations].select do |violation|
        violation.type == 'FAIL'
      end
      expect(violations.map(&:id)).to eq %w[F38 F3]
    end
  end
end
