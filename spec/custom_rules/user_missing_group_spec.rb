require 'spec_helper'
require 'custom_rules/security_group_missing_egress'


describe UserMissingGroupRule do

  context 'when resource template creates iam user with no group' do
    before(:all) do
      template_name = 'iam_user_with_no_group.json'
      @cfn_model = CfnModel.new.parse(IO.read(File.join(__dir__, '..', 'test_templates', template_name)))
    end

    it 'fails validation' do
      security_group_egress_rule = UserMissingGroupRule.new
      violation_count = security_group_egress_rule.audit @cfn_model

      expect(violation_count).to eq 1
    end
  end

  context 'when resource template creates iam user with two groups' do
    before(:all) do
      template_name = 'iam_user_with_two_groups_through_addition.json'
      @cfn_model = CfnModel.new.parse(IO.read(File.join(__dir__, '..', 'test_templates', template_name)))
    end

    it 'passes validation' do
      security_group_egress_rule = SecurityGroupMissingEgressRule.new
      violation_count = security_group_egress_rule.audit @cfn_model

      expect(violation_count).to eq 0
    end
  end
end