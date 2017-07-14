require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/SecurityGroupIngressOpenToWorldRule'

describe SecurityGroupIngressOpenToWorldRule do
  context 'security group with ingress rules open to world via 0.0.0.0/0' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/security_group/security_group_open_to_world_on_ingress.json')

      actual_logical_resource_ids = SecurityGroupIngressOpenToWorldRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w(sgOpenIngress sgOpenIngress2)

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'standalone egress (to external sg) with cidrip of 0.0.0.0/0' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/security_group/standalone_ingress_open_to_world.json')

      actual_logical_resource_ids = SecurityGroupIngressOpenToWorldRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w(securityGroupIngress)

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

end
