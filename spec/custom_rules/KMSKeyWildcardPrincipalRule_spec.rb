require 'spec_helper'
require 'cfn-nag/custom_rules/KMSKeyWildcardPrincipalRule'
require 'cfn-model'

describe KMSKeyWildcardPrincipalRule do
  describe 'AWS::KMS::Key' do
    context 'when a principal is not set to a wildcard' do
      it 'does not return an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/kms/kms_key_without_wildcard_principal.json')
        actual_logical_resource_ids = KMSKeyWildcardPrincipalRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end
    context 'when a principal is set to a wildcard' do
      it 'returns an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/kms/kms_key_with_wildcard_principal.json')
        actual_logical_resource_ids = KMSKeyWildcardPrincipalRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq ['myKeyWildcardPrincipal']
      end
    end
    context 'when a principal\'s AWS key is set to a wildcard' do
      it 'returns an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/kms/kms_key_with_aws_wildcard_principal.json')
        actual_logical_resource_ids = KMSKeyWildcardPrincipalRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq ['myKeyAwsWildcardPrincipal']
      end
    end
    context 'when a principal\'s AWS key is an array and contains a wildcard' do
      it 'returns an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/kms/kms_key_with_aws_array_wildcard_principal.json')
        actual_logical_resource_ids = KMSKeyWildcardPrincipalRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq ['myKeyAwsArrayWildcardPrincipal']
      end
    end
  end
end
