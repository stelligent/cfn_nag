# frozen_string_literal: true

require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/SecretsManagerSecretKmsKeyIdRule'

describe SecretsManagerSecretKmsKeyIdRule do
  context 'missing kms key id' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/secretsmanager/conditional_properties.yml')

      actual_logical_resource_ids = SecretsManagerSecretKmsKeyIdRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[AppDbSecret]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'has explicit kms key id' do
    it 'returns no logical resource ids' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/secretsmanager/explicit_key.yml')

      expect(SecretsManagerSecretKmsKeyIdRule.new.audit(cfn_model)).to be nil
    end
  end
end
