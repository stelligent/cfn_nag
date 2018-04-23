require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/SecurityGroupIngressCidrNon32Rule'

describe SecurityGroupIngressCidrNon32Rule do
  context 'security group with ingress rules open to a cidr that is not /32' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/security_group/non_32_cidr_standalone_ingress.json')

      actual_logical_resource_ids = SecurityGroupIngressCidrNon32Rule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[sg]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'dangling security group ingress rules open to a cidr that is not /32' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/security_group/dangling_ingress_rule.json')

      actual_logical_resource_ids = SecurityGroupIngressCidrNon32Rule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[danglingIngress]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'security group ingress rules open to an ip6 cidr that is not /128' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/security_group/non_32_cidr_with_ip6.json')

      actual_logical_resource_ids = SecurityGroupIngressCidrNon32Rule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[sgDualModel securityGroupIngress]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
