# frozen_string_literal: true

require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/ElasticsearchDomainInsideVPCRule'

describe ElasticsearchDomainInsideVPCRule do

  describe 'AWS::Elasticsearch::Domain' do
    context 'when Elasticsearch domain is inside VPC' do
      it 'does not return an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/elasticsearch/elasticsearch_inside_vpc.json')
        actual_logical_resource_ids = ElasticsearchDomainInsideVPCRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end
  end

  describe 'AWS::Elasticsearch::Domain' do
    context 'when Elasticsearch domain is not inside VPC' do
      it 'does return an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/elasticsearch/elasticsearch_not_inside_vpc.json')
        actual_logical_resource_ids = ElasticsearchDomainInsideVPCRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq ["ElasticsearchDomainNotInVPC"]
      end
    end
   end
   
end