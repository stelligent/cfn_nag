require 'spec_helper'
require 'cfn-nag/custom_rules/ElasticsearchDomainNodeToNodeEncryptionOptionsRule'
require 'cfn-model'

describe ElasticsearchDomainNodeToNodeEncryptionOptionsRule do
  describe 'Detect missing nodeToNodeEncryptionOptions scenarios' do
    context 'two elasticsearch domains missing nodeToNodeEncryptionOptions' do
      it 'returns a list of offending elasticsearch domain ids' do
        cfn_model = CfnParser.new.parse read_test_template('json/elasticsearch/elasticsearch_domain_no_encryption_node_to_node.json')
        actual_logical_resource_ids = ElasticsearchDomainNodeToNodeEncryptionOptionsRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq ['ElasticsearchDomainWithName', 'ElasticsearchDomainWithName2']
      end
    end
  end
  describe 'Correct configured elastic search domain' do
    context '1 elasticsearch domains with nodeToNodeEncryptionOptions enabled' do
      it 'returns a empty list ' do
        cfn_model = CfnParser.new.parse read_test_template('json/elasticsearch/elasticsearch_domain_with_encryption_node_to_node.json')
        actual_logical_resource_ids = ElasticsearchDomainNodeToNodeEncryptionOptionsRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end
  end
  
end
