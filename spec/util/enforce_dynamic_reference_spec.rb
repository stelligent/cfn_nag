require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/util/enforce_dynamic_reference'

describe 'dynamic_reference_property_value', :rule do
  context 'test function dynamic_reference_property_value' do
    it 'returns true if everything is fine, nothing is ruined' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/rds_dbcluster/rds_dbcluster_master_user_password_secrets_manager.yml'
      )
      cfn_model.resources_by_type('AWS::RDS::DBCluster')
               .select do |cluster|
        raise "masterUserPassword shouldn't be nil" if cluster.masterUserPassword.nil?

        expect(dynamic_reference_property_value?(cfn_model, cluster.masterUserPassword)).to eq true
      end
    end

    it 'returns false if there is a problem' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/rds_dbcluster/rds_dbcluster_master_user_password_ssm.yml'
      )
      cfn_model.resources_by_type('AWS::RDS::DBCluster')
               .select do |cluster|
        raise "masterUserPassword shouldn't be nil" if cluster.masterUserPassword.nil?

        expect(dynamic_reference_property_value?(cfn_model, cluster.masterUserPassword)).to eq false
      end
    end

    it 'returns false in edge case masterUserPassword is not a string' do
      cfn_model = double('cfn_model')

      expect(dynamic_reference_property_value?(cfn_model, 'Ref': 'MasterUserPassword')).to eq false
    end
  end
end
