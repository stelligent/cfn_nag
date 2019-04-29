require 'spec_helper'
require 'cfn-nag/custom_rules/SecurityGroupCustomNameRule'
require 'cfn-model'

describe SecurityGroupCustomNameRule do
  before(:all) do
    template_name = 'json/security_group/custom_named_resource_rule.json'
    @cfn_model = CfnParser.new.parse read_test_template(template_name)
  end
  context 'when a security group has a custom name' do
		it 'returns offending logical resource id' do
      actual_logical_resource_ids = SecurityGroupCustomNameRule.new.audit_impl @cfn_model

      expect(actual_logical_resource_ids).to eq %w[sg]
    end
  end

  context 'when a security group does not have a custom name' do
		it 'does not return a logical resource id' do
      actual_logical_resource_ids = SecurityGroupCustomNameRule.new.audit_impl @cfn_model

      expect(actual_logical_resource_ids).not_to include 'sg2'
    end
  end
end
