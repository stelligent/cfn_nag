require 'spec_helper'
require 'custom_rules/security_group_missing_egress'


describe SecurityGroupMissingEgressRule do

  context 'when resource template creates single security group with no egress rules' do
    before(:all) do
      template_name = 'single_security_group_empty_ingress.json'
      @cfn_model = CfnModel.new.parse(IO.read(File.join(__dir__, '..', 'test_templates', template_name)))
    end

    it 'fails validation' do
      security_group_egress_rule = SecurityGroupMissingEgressRule.new
      violation_count = security_group_egress_rule.audit @cfn_model

      expect(violation_count).to eq 1
    end
  end

  context 'when resource template creates single security group with one egress rule' do
    before(:all) do
      template_name = 'single_security_group_single_egress.json'
      @cfn_model = CfnModel.new.parse(IO.read(File.join(__dir__, '..', 'test_templates', template_name)))
    end

    it 'passes validation' do
      security_group_egress_rule = SecurityGroupMissingEgressRule.new
      violation_count = security_group_egress_rule.audit @cfn_model

      expect(violation_count).to eq 0
    end
  end

  context 'when resource template creates single security group with two external egress rule' do
    before(:all) do
      template_name = 'single_security_group_two_externalized_egress.json'
      @cfn_model = CfnModel.new.parse(IO.read(File.join(__dir__, '..', 'test_templates', template_name)))
    end

    it 'fails validation' do
      security_group_egress_rule = SecurityGroupMissingEgressRule.new
      violation_count = security_group_egress_rule.audit @cfn_model

      expect(violation_count).to eq 0
    end
  end
end