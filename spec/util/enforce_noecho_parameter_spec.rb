require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/util/enforce_noecho_parameter'

describe 'no_echo_parameter_without_default', :rule do

  context 'test function no_echo_parameter_without_default' do
    it 'returns true if everything is fine, nothing is ruined' do
      cfn_model = CfnParser.new.parse read_test_template('json/rds_instance/rds_instance_no_echo_username.json')
      cfn_model.resources_by_type('AWS::RDS::DBInstance')
               .select do |instance|
        if instance.masterUsername.nil?
          fail "masterUsername shouldn't be nil"
        else
          expect(no_echo_parameter_without_default?(cfn_model, instance.masterUsername))
            .to eq true
        end
      end
    end

    it 'returns false if there is a problem' do
      cfn_model = CfnParser.new.parse read_test_template('json/rds_instance/rds_instance_no_echo_with_default_username.json')
      cfn_model.resources_by_type('AWS::RDS::DBInstance')
        .select do |instance|
        if instance.masterUsername.nil?
          fail "masterUsername shouldn't be nil"
        else
          expect(no_echo_parameter_without_default?(cfn_model, instance.masterUsername))
            .to eq false
        end
      end
    end

    it 'returns false in edge case masterUsername is not a hash' do
      cfn_model = double("cfn_model")

      expect(no_echo_parameter_without_default?(cfn_model, 'Not A Hash'))
        .to eq false
    end

    it 'returns false in edge case key to check is not a ref' do
      cfn_model = double("cfn_model")
      expect(no_echo_parameter_without_default?(cfn_model, {"NotRef" => "Thing"}))
        .to eq false
    end

    it 'returns false if masterUsername has a ref to nonexistent parameter' do
      cfn_model = double("cfn_model")

      allow(cfn_model).to receive(:parameters).and_return({})

      expect(no_echo_parameter_without_default?(cfn_model, { "Ref" => "Username" }))
        .to eq false
    end
  end
end
