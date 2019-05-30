require 'spec_helper'
require 'cfn-nag/cfn_nag_config'
require 'cfn-nag/cfn_nag'

describe CfnNag do
  before(:all) do
    CfnNagLogging.configure_logging(debug: false)
    @cfn_nag = CfnNag.new(config: CfnNagConfig.new)
  end

  context 'two load balancers without access logging enabled' do
    it 'flags a warning' do
      template_name = 'json/elasticloadbalancing_loadbalancer/two_load_balancers_with_no_logging.json'

      expected_aggregate_results = [
        {
          filename: test_template_path(template_name),
          file_results: {
            failure_count: 0,
            violations: [
              Violation.new(
                id: 'W26', type: Violation::WARNING,
                message:
                'Elastic Load Balancer should have access logging enabled',
                logical_resource_ids: %w[elb1 elb2],
                line_numbers: [4, 19]
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
