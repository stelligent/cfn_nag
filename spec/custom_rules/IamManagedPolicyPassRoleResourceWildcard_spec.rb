# frozen_string_literal: true

require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/IamManagedPolicyPassRoleWildcardResourceRule'

describe IamManagedPolicyPassRoleWildcardResourceRule do
  context 'A managed policy containing both a * resource and PassRole action' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/iam_passrole_resource_wildcard/iam_managed_policy_passrole_resource_wildcard_fail.yml')

      actual_logical_resource_ids = IamManagedPolicyPassRoleWildcardResourceRule.new.audit_impl cfn_model

      expected_logical_resource_ids = %w[ManagedPolicyFail1
                                         ManagedPolicyFail2
                                         ManagedPolicyFail3
                                         ManagedPolicyFail4
                                         ManagedPolicyFail5]
      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'A managed policy not containing both a * resource and PassRole action' do
    it 'does not return offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/iam_passrole_resource_wildcard/iam_managed_policy_passrole_resource_wildcard_pass.yml')

      actual_logical_resource_ids = IamManagedPolicyPassRoleWildcardResourceRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
