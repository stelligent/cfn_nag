require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/ElasticLoadBalancerV2ListenerProtocolRule'

describe ElasticLoadBalancerV2ListenerProtocolRule do
  context 'listener with an HTTP protocol' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/elasticloadbalacingv2_listener/listener_with_http_protocol.yml'
      )

      actual_logical_resource_ids = ElasticLoadBalancerV2ListenerProtocolRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[HTTPlistener]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'listener with an HTTPS protocol' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/elasticloadbalacingv2_listener/listener_with_TLS_1_2_ssl_policy.yml'
      )

      actual_logical_resource_ids = ElasticLoadBalancerV2ListenerProtocolRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
