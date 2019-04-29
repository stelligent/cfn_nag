require 'spec_helper'
require 'cfn-nag/custom_rules/ResourceWithCustomNameRule'
require 'cfn-model'

describe ResourceWithCustomNameRule do
  describe 'AWS::IAM::Role' do
    context 'when a custom name is provided' do
      it 'returns offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/iam_role/iam_role_with_custom_name.json')
        actual_logical_resource_ids = ResourceWithCustomNameRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq ['RoleWithName']
      end
    end

    context 'when a custom name is provided as an empty string' do
      it 'returns offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/iam_role/iam_role_with_custom_name_empty_string.json')
        actual_logical_resource_ids = ResourceWithCustomNameRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq ['RoleWithEmptyName']
      end
    end

    context 'when a custom name is not provided' do
      it 'does not return a logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/iam_role/iam_role_without_custom_name.json')
        actual_logical_resource_ids = ResourceWithCustomNameRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end
  end

  describe 'AWS::EC2::SecurityGroup' do
    context 'when a custom name is provided' do
      it 'returns offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/security_group/security_group_with_custom_name.json')
        actual_logical_resource_ids = ResourceWithCustomNameRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq %w[sgWithName]
      end
    end

    context 'when a custom name is not provided' do
      it 'does not return a logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/security_group/security_group_without_custom_name.json')
        actual_logical_resource_ids = ResourceWithCustomNameRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end
  end
end
