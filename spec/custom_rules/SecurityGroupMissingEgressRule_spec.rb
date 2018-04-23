require 'spec_helper'
require 'cfn-nag/custom_rules/SecurityGroupMissingEgressRule'
require 'cfn-model'

describe SecurityGroupMissingEgressRule do
  context 'when resource template creates single security group with no egress rules' do
    before(:all) do
      template_name = 'json/security_group/single_security_group_empty_ingress.json'
      @cfn_model = CfnParser.new.parse read_test_template(template_name)
    end

    it 'fails validation' do
      security_group_egress_rule = SecurityGroupMissingEgressRule.new
      violation = security_group_egress_rule.audit @cfn_model

      expect(violation).to_not be_nil
    end
  end

  context 'when resource template creates single security group with one egress rule' do
    before(:all) do
      template_name = 'json/security_group/single_security_group_single_egress.json'
      @cfn_model = CfnParser.new.parse read_test_template(template_name)
    end

    it 'passes validation' do
      security_group_egress_rule = SecurityGroupMissingEgressRule.new
      violation = security_group_egress_rule.audit @cfn_model

      expect(violation).to be_nil
    end
  end

  context 'when resource template creates single security group with two external egress rule' do
    before(:all) do
      template_name = 'json/security_group/single_security_group_two_externalized_egress.json'
      @cfn_model = CfnParser.new.parse read_test_template(template_name)
    end

    it 'passes validation' do
      security_group_egress_rule = SecurityGroupMissingEgressRule.new
      violation = security_group_egress_rule.audit @cfn_model

      puts violation
      expect(violation).to be_nil
    end
  end
end
