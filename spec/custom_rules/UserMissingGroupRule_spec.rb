require 'spec_helper'
require 'cfn-nag/custom_rules/UserMissingGroupRule'
require 'cfn-model'

describe UserMissingGroupRule do
  context 'when resource template creates iam user with no group' do
    before(:all) do
      template_name = 'json/iam_user/iam_user_with_no_group.json'
      @cfn_model = CfnParser.new.parse read_test_template(template_name)
    end

    it 'fails validation' do
      security_group_egress_rule = UserMissingGroupRule.new
      violation = security_group_egress_rule.audit @cfn_model

      expect(violation).to_not be_nil
    end
  end

  context 'when resource template creates iam user with two groups' do
    before(:all) do
      template_name = 'json/iam_user/iam_user_with_two_groups_through_addition.json'
      @cfn_model = CfnParser.new.parse read_test_template(template_name)
    end

    it 'passes validation' do
      security_group_egress_rule = SecurityGroupMissingEgressRule.new
      violation = security_group_egress_rule.audit @cfn_model

      expect(violation).to be_nil
    end
  end
end
