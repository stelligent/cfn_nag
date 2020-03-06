require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/SecurityGroupEgressAllProtocolsRule'

describe SecurityGroupEgressAllProtocolsRule do
  context 'security group with egress rules open to all protocols' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/security_group/dangling_allprotocols_egress_rule.json')

      actual_logical_resource_ids = SecurityGroupEgressAllProtocolsRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[securityGroupEgress2 IpProtocol_minus_1_str]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'security group with cidr of ip4 localhost open to all protocols' do
    it 'ignores the localhost egress ' do
      cfn_model = CfnParser.new.parse read_test_template('json/security_group/security_group_ip4_localhost_egress.json')

      actual_logical_resource_ids = SecurityGroupEgressAllProtocolsRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[sg991]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'security group with cidr of ip6 localhost open to all protocols' do
    it 'ignores the localhost egress ' do
      cfn_model = CfnParser.new.parse read_test_template('json/security_group/security_group_ip6_localhost_egress.json')

      actual_logical_resource_ids = SecurityGroupEgressAllProtocolsRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
