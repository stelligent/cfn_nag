require 'spec_helper'
require 'cfn-nag/custom_rules/KMSKeyRotationRule'
require 'cfn-model'

describe KMSKeyRotationRule do
  describe 'AWS::KMS::Key' do
    context 'when key rotation is explicitly set to true' do
      it 'does not return an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/kms/kms_key_with_enable_key_rotation_true.json')
        actual_logical_resource_ids = KMSKeyRotationRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end
    context 'when key rotation is explicitly set to true as a string' do
      it 'does not return an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/kms/kms_key_with_enable_key_rotation_true_string.json')
        actual_logical_resource_ids = KMSKeyRotationRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end
    context 'when key rotation is explicitly set to false' do
      it 'returns an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/kms/kms_key_with_enable_key_rotation_false.json')
        actual_logical_resource_ids = KMSKeyRotationRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq ['myKeyRotationExplicitlyFalse']
      end
    end
    context 'when key rotation is explicitly set to false as a string' do
      it 'returns an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/kms/kms_key_with_enable_key_rotation_false_string.json')
        actual_logical_resource_ids = KMSKeyRotationRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq ['myKeyRotationExplicitlyFalseString']
      end
    end
    context 'when key rotation is absent' do
      it 'returns an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/kms/kms_key_with_enable_key_rotation_absent.json')
        actual_logical_resource_ids = KMSKeyRotationRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq ['myKeyRotationAbsent']
      end
    end
  end
end
