# frozen_string_literal: true

require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/IamRolePassRoleWildcardResourceRule'

describe IamRolePassRoleWildcardResourceRule do
  context 'A role with an inline policy containing a * resource and PassRole action' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/iam_passrole_resource_wildcard/iam_role_passrole_resource_wildcard_fail.yml')

      actual_logical_resource_ids = IamRolePassRoleWildcardResourceRule.new.audit_impl cfn_model

      expected_logical_resource_ids = %w[RoleFail1 RoleFail2]
      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'A role with an inline policy not containing both a * resource and PassRole action' do
    it 'does not return offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/iam_passrole_resource_wildcard/iam_role_passrole_resource_wildcard_pass.yml')

      actual_logical_resource_ids = IamRolePassRoleWildcardResourceRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
