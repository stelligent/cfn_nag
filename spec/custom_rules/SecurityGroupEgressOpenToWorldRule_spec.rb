require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/SecurityGroupEgressOpenToWorldRule'

describe SecurityGroupEgressOpenToWorldRule do
  context 'security group with egress rules open to 0.0.0.0/0' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/security_group/security_group_open_to_world_on_egress.json')

      actual_logical_resource_ids = SecurityGroupEgressOpenToWorldRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[sgOpenEgress sgOpenEgress2]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'standalone egress (to external sg) with cidrip of 0.0.0.0/0' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/security_group/standalone_egress_open_to_world.json')

      actual_logical_resource_ids = SecurityGroupEgressOpenToWorldRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[securityGroupEgress]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'egress with cidrip of ::/0' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/security_group/ip6_security_group_egress_open_to_world.yml')

      actual_logical_resource_ids = SecurityGroupEgressOpenToWorldRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[InstanceSecurityGroup InstanceSecurityGroup2 InstanceSecurityGroup3 securityGroupEgress]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'egress with cidrip of 0.0.0.0/0 in a pesky if with a FindInMap' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/security_group/pesky_if.yml')

      actual_logical_resource_ids = SecurityGroupEgressOpenToWorldRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[SG]
      #puts cfn_model.resources['SG'].securityGroupEgress
      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
