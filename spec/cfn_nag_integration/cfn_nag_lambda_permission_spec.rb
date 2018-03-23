require 'spec_helper'
require 'cfn-nag/cfn_nag'

describe CfnNag do
  before(:all) do
    CfnNag.configure_logging(debug: false)
    @cfn_nag = CfnNag.new
  end

  context 'lambda permission with some out of the ordinary items', :lambda do
    it 'flags a warning' do
      template_name = 'json/lambda_permission/lambda_with_wildcard_principal_and_non_invoke_function_permission.json'

      expected_aggregate_results = [
        {
          filename: test_template_path(template_name),
          file_results: {
            failure_count: 2,
            violations: [
              Violation.new(id: 'F3',
                            type: Violation::FAILING_VIOLATION,
                            message: 'IAM role should not allow * action on its permissions policy',
                            logical_resource_ids: %w[LambdaExecutionRole]),
              Violation.new(id: 'W11',
                            type: Violation::WARNING,
                            message: 'IAM role should not allow * resource on its permissions policy',
                            logical_resource_ids: %w[LambdaExecutionRole]),
              Violation.new(id: 'W24',
                            type: Violation::WARNING,
                            message: 'Lambda permission beside InvokeFunction might not be what you want?  Not sure!?',
                            logical_resource_ids: %w[lambdaPermission]),
              Violation.new(id: 'F13',
                            type: Violation::FAILING_VIOLATION,
                            message: 'Lambda permission principal should not be wildcard',
                            logical_resource_ids: %w[lambdaPermission])
            ]
          }
        }
      ]

      actual_aggregate_results = @cfn_nag.audit_aggregate_across_files(input_path: test_template_path(template_name))
      expect(actual_aggregate_results).to eq expected_aggregate_results
    end
  end
end
