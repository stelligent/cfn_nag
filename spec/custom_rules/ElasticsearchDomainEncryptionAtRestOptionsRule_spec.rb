require 'spec_helper'
require 'cfn-nag/custom_rules/ElasticsearchDomainEncryptionAtRestOptionsRule'
require 'cfn-model'

describe ElasticsearchDomainEncryptionAtRestOptionsRule do
  describe 'Detect missing encryptionAtRestOptions scenarios' do
    context 'two elasticsearch domains missing encryptionAtRestOptions' do
      it 'returns a list of offending elasticsearch domain ids' do
        cfn_model = CfnParser.new.parse read_test_template('json/elasticsearch/elasticsearch_domain_no_encryption_at_rest.json')
        actual_logical_resource_ids = ElasticsearchDomainEncryptionAtRestOptionsRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq ['ElasticsearchDomainWithName', 'ElasticsearchDomainWithName2']
      end
    end
  end
  describe 'Correct configured elastic search domain' do
    context '1 elasticsearch domains with encryptionAtRestOptions' do
      it 'returns a empty list ' do
        cfn_model = CfnParser.new.parse read_test_template('json/elasticsearch/elasticsearch_domain_with_encryption_at_rest.json')
        actual_logical_resource_ids = ElasticsearchDomainEncryptionAtRestOptionsRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end
  end
  
end
