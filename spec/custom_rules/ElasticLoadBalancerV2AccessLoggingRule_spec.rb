require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/ElasticLoadBalancerV2AccessLoggingRule'

describe ElasticLoadBalancerV2AccessLoggingRule do
  context 'two load balancers V2 without access logging enabled' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'json/elasticloadbalancing_loadbalancer_v2/two_load_balancers_with_no_logging.json'
      )

      actual_logical_resource_ids = ElasticLoadBalancerV2AccessLoggingRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[elb1 elb2]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'load balancer with conditional access logging at the property' do
    it 'returns offending logical resource id depending on condition' do
      cfn_model = CfnParser.new.parse read_test_template(
                                        'yaml/elasticloadbalacingv2_elasticloadbalancer/conditional_properties.yml'
                                      )

      actual_logical_resource_ids = ElasticLoadBalancerV2AccessLoggingRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids

      cfn_model = CfnParser.new.parse read_test_template(
                                        'yaml/elasticloadbalacingv2_elasticloadbalancer/conditional_properties.yml'
                                      ), nil, false, '{"EnableLogsPublicLB":false}'

      actual_logical_resource_ids = ElasticLoadBalancerV2AccessLoggingRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[ApplicationLoadBalancer]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'load balancer with conditional access logging at the property value' do
    it 'returns offending logical resource id depending on condition' do
      cfn_model = CfnParser.new.parse read_test_template(
                                        'yaml/elasticloadbalacingv2_elasticloadbalancer/conditional_property_values.yml'
                                      )

      actual_logical_resource_ids = ElasticLoadBalancerV2AccessLoggingRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids

      cfn_model = CfnParser.new.parse read_test_template(
                                        'yaml/elasticloadbalacingv2_elasticloadbalancer/conditional_properties.yml'
                                      ), nil, false, '{"EnableLogsPublicLB":false}'

      actual_logical_resource_ids = ElasticLoadBalancerV2AccessLoggingRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[ApplicationLoadBalancer]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
