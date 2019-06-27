require 'spec_helper'
require 'password_rule_spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/RedshiftClusterMasterUserPasswordRule'

describe RedshiftClusterMasterUserPasswordRule, :rule do
  before(:all) do
    @resource_type = 'AWS::Redshift::Cluster'
    @password_property = 'MasterUserPassword'
    @test_template_type = 'yaml'
  end

  password_rule_test_sets.each do |test_description, desired_test_result|
    context "Redshift Cluster MasterUserPassword #{test_description}" do
      before(:all) do
        @test_description = test_description
        @desired_test_result = desired_test_result
      end

      it context_return_value(desired_test_result) do
        run_test(@resource_type, @password_property, @test_template_type,
                 @test_description, @desired_test_result)
      end
    end
  end
end
