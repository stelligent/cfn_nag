require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/SecurityGroupIngressPortRangeRule2'

describe SecurityGroupIngressPortRangeRule2 do
#   context 'security group with ingress rules open to port range' do
#     it 'returns offending logical resource id' do
#       cfn_model = CfnParser.new.parse read_test_template('json/security_group/single_security_group_one_cidr_ingress.json')

#       actual_logical_resource_ids = SecurityGroupIngressPortRangeRule2.new.audit_impl cfn_model
#       expected_logical_resource_ids = %w[sg]

#       expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
#     end
#   end

  context 'dangling security group ingress rules open to port range' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/security_group/dangling_ingress_rule_2.json')

      actual_logical_resource_ids = SecurityGroupIngressPortRangeRule2.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[danglingIngress]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
