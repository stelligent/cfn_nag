require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/ElasticLoadBalancerV2ListenerSslPolicyRule'

describe ElasticLoadBalancerV2ListenerSslPolicyRule do
  context 'listener with a pre-TLS 1.2 ssl policy' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/elasticloadbalacingv2_listener/listener_with_pre_TLS_1_2_ssl_policy.yml'
      )

      actual_logical_resource_ids = ElasticLoadBalancerV2ListenerSslPolicyRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[HTTPSlistener]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'listener with a TLS 1.2 ssl policy' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/elasticloadbalacingv2_listener/listener_with_TLS_1_2_ssl_policy.yml'
      )

      actual_logical_resource_ids = ElasticLoadBalancerV2ListenerSslPolicyRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'listener with HTTPS protocol missing ssl policy' do
    it 'returns the default offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/elasticloadbalacingv2_listener/listener_with_TLS_1_2_and_no_ssl_policy.yml'
      )

      actual_logical_resource_ids = ElasticLoadBalancerV2ListenerSslPolicyRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[HTTPSlistener]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'listener with HTTP protocol missing ssl policy' do
    it 'returns an empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/elasticloadbalacingv2_listener/listener_with_pre_TLS_1_2_and_no_ssl_policy.yml'
      )

      actual_logical_resource_ids = ElasticLoadBalancerV2ListenerSslPolicyRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
