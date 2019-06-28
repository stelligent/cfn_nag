require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/util/enforce_string_or_dynamic_reference'

describe 'insecure_string_or_dynamic_reference', :rule do
  context 'test function insecure_string_or_dynamic_reference' do
    it 'returns false if everything is fine, nothing is ruined' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/rds_dbcluster/' \
        'rds_dbcluster_master_user_password_from_secrets_manager.yaml'
      )
      cfn_model.resources_by_type('AWS::RDS::DBCluster')
               .select do |cluster|
        raise "masterUserPassword shouldn't be nil" if cluster.masterUserPassword.nil?

        expect(insecure_string_or_dynamic_reference?(cfn_model, cluster.masterUserPassword)).to eq false
      end
    end

    it 'returns true if there is a problem' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/rds_dbcluster/' \
        'rds_dbcluster_master_user_password_from_systems_manager.yaml'
      )
      cfn_model.resources_by_type('AWS::RDS::DBCluster')
               .select do |cluster|
        raise "masterUserPassword shouldn't be nil" if cluster.masterUserPassword.nil?

        expect(insecure_string_or_dynamic_reference?(cfn_model, cluster.masterUserPassword)).to eq true
      end
    end

    it 'returns false in edge case masterUserPassword is not a string' do
      cfn_model = double('cfn_model')

      expect(insecure_string_or_dynamic_reference?(cfn_model, 'Ref': 'MasterUserPassword')).to eq false
    end
  end
end
