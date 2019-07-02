# frozen_string_literal: true

require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/SecurityGroupRuleDescriptionRule'

describe SecurityGroupRuleDescriptionRule do
  context 'security group rules missing description' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/security_group/security_group_rule_description_fail.yml')

      actual_logical_resource_ids = SecurityGroupRuleDescriptionRule.new.audit_impl(cfn_model).sort
      expected_logical_resource_ids = %w[
        SecurityGroupInlineRules1
        SecurityGroupInlineRules2
        SecurityGroupIngress
        SecurityGroupEgress
      ].sort
      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'security group rules containing description' do
    it 'does not return offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/security_group/security_group_rule_description_pass.yml')

      actual_logical_resource_ids = SecurityGroupRuleDescriptionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
