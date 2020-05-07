require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/SPCMRule'

describe SPCMRule do
  context 'iam role with complexity 2 and threshold 1' do
    it 'returns offending iam role' do
      cfn_model = CfnParser.new.parse read_test_template('json/iam_role/iam_role_with_wildcard_action.json')

      rule = SPCMRule.new
      rule.spcm_threshold = 1
      actual_logical_resource_ids = rule.audit_impl cfn_model
      expected_logical_resource_ids = %w[WildcardActionRole]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end


  end

  context 'iam role with complexity 2 and threshold 2' do
    it 'ignores iam role' do
      cfn_model = CfnParser.new.parse read_test_template('json/iam_role/iam_role_with_wildcard_action.json')

      rule = SPCMRule.new
      rule.spcm_threshold = 3
      actual_logical_resource_ids = rule.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'A policy not containing both a * resource and PassRole action and threshold 1' do
    it 'returns offending iam policy' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/iam_passrole_resource_wildcard/iam_inline_policy_passrole_resource_wildcard_pass.yml')

      rule = SPCMRule.new
      rule.spcm_threshold = 1
      actual_logical_resource_ids = rule.audit_impl cfn_model
      expected_logical_resource_ids = %w[InlinePolicyPass]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
