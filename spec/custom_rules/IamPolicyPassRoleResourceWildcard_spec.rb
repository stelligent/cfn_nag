# frozen_string_literal: true

require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/IamPolicyPassRoleWildcardResourceRule'

describe IamPolicyPassRoleWildcardResourceRule do
  context 'A policy containing both a * resource and PassRole action' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/iam_passrole_resource_wildcard/iam_inline_policy_passrole_resource_wildcard_fail.yml')

      actual_logical_resource_ids = IamPolicyPassRoleWildcardResourceRule.new.audit_impl cfn_model

      expected_logical_resource_ids = %w[InlinePolicyFail]
      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'A policy not containing both a * resource and PassRole action' do
    it 'does not return offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/iam_passrole_resource_wildcard/iam_inline_policy_passrole_resource_wildcard_pass.yml')

      actual_logical_resource_ids = IamPolicyPassRoleWildcardResourceRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
