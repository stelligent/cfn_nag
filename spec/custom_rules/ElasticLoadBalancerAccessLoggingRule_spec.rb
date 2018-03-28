require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/ElasticLoadBalancerAccessLoggingRule'

describe ElasticLoadBalancerAccessLoggingRule do
  context 'two load balancers without access logging enabled' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'json/elasticloadbalancing_loadbalancer/two_load_balancers_with_no_logging.json'
      )

      actual_logical_resource_ids = ElasticLoadBalancerAccessLoggingRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[elb1 elb2]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
