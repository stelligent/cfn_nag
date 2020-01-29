require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/util/enforce_reference_parameter'

describe 'insecure_parameter', :rule do
  context 'test function insecure_parameter' do
    it 'returns false if everything is fine, nothing is ruined' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/rds_dbcluster/' \
        'rds_dbcluster_master_user_password_parameter_with_noecho.yaml'
      )
      cfn_model.resources_by_type('AWS::RDS::DBCluster')
               .select do |cluster|
        raise "masterUserPassword shouldn't be nil" if cluster.masterUserPassword.nil?

        expect(insecure_parameter?(cfn_model, cluster.masterUserPassword)).to eq false
      end
    end

    it 'returns false if AWS::NoValue Pseudo Parameter is used' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/rds_dbcluster/' \
        'rds_dbcluster_master_user_password_with_novalue_pseudo_parameter.yaml'
      )
      cfn_model.resources_by_type('AWS::RDS::DBCluster')
               .select do |cluster|
        raise "masterUserPassword shouldn't be nil" if cluster.masterUserPassword.nil?

        expect(cluster.masterUserPassword).to eq "Ref"=>"AWS::NoValue"
        expect(insecure_parameter?(cfn_model, cluster.masterUserPassword)).to eq false
      end
    end

    it 'returns true if there is a problem' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/rds_dbcluster/' \
        'rds_dbcluster_master_user_password_parameter_with_noecho_and_default_value.yaml'
      )
      cfn_model.resources_by_type('AWS::RDS::DBCluster')
               .select do |cluster|
        raise "masterUserPassword shouldn't be nil" if cluster.masterUserPassword.nil?

        expect(insecure_parameter?(cfn_model, cluster.masterUserPassword)).to eq true
      end
    end

    it 'returns false in edge case masterUserPassword is not a hash' do
      cfn_model = double('cfn_model')
      expect(insecure_parameter?(cfn_model, 'Not A Hash')).to eq false
    end

    it 'returns false in edge case key to check is not a ref' do
      cfn_model = double('cfn_model')
      expect(insecure_parameter?(cfn_model, 'NotRef': 'Thing')).to eq false
    end

    it 'returns false if masterUserPassword has a ref to nonexistent parameter' do
      cfn_model = double('cfn_model')

      allow(cfn_model).to receive(:parameters).and_return({})

      expect(insecure_parameter?(cfn_model, 'Ref': 'MasterUserPassword')).to eq false
    end
  end
end
