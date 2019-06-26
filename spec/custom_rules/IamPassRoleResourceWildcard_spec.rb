require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/IamRolePassRoleWildcardResourceRule'

describe IamRolePassRoleWildcardResourceRule do
  context 'role with a * resource and PassRole action' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/iam_passrole_resource_wildcard/iam_role_passrole_resource_wildcard_fail.yml')

      actual_logical_resource_ids = IamRolePassRoleWildcardResourceRule.new.audit_impl cfn_model

      expected_logical_resource_ids = %w[NotActionPolicy]
      puts expected_logical_resource_ids
      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'role not containing both a * resource and PassRole action' do
    it 'Does not return offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/iam_passrole_resource_wildcard/iam_role_passrole_resource_wildcard_pass.yml')

      actual_logical_resource_ids = IamRolePassRoleWildcardResourceRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[NotActionPolicy]

      expect(actual_logical_resource_ids).to eq []
    end
  end

end