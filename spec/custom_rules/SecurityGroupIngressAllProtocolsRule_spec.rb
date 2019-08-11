require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/SecurityGroupIngressAllProtocolsRule'

describe SecurityGroupIngressAllProtocolsRule do

  context 'dangling security group ingress rules open to port range' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/security_group/dangling_allprotocols_ingress_rule.json')

      actual_logical_resource_ids = SecurityGroupIngressAllProtocolsRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[danglingIngress IpProtocol_minus_1_str]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
