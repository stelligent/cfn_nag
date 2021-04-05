# frozen_string_literal: true

require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/DMSReplicationInstanceNotPublicRule'

describe DMSReplicationInstanceNotPublicRule do

  describe 'AWS::DMS::ReplicationInstance' do
    context 'when Database Migration Service replication instances are not public' do
      it 'does not return an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/dms_replication_instance/dms-replication-instance-is-not-public.json')
        actual_logical_resource_ids = DMSReplicationInstanceNotPublicRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end
  end

  describe 'AWS::DMS::ReplicationInstance' do
    context 'when Database Migration Service replication instance is public' do
      it 'does return an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/dms_replication_instance/dms-replication-instance-public.json')
        actual_logical_resource_ids = DMSReplicationInstanceNotPublicRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq ["BasicReplicationInstance"]
      end
    end
   end
   
end
