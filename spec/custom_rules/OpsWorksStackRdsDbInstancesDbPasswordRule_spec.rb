require 'spec_helper'
require 'password_rule_spec_helper'
require 'cfn-model'

resource_type = 'AWS::OpsWorks::Stack'
password_property = 'RdsDbInstances'
sub_property_name = 'DbPassword'
test_template_type = 'yaml'

require "cfn-nag/custom_rules/#{rule_name(resource_type, password_property, sub_property_name)}"

describe Object.const_get(rule_name(resource_type, password_property, sub_property_name)), :rule do
  # Creates dynamic set of contexts based on the password_rule_test_sets hash
  password_rule_test_sets.each do |test_description, desired_test_result|
    context "#{resource_type} #{password_property} #{sub_property_name} #{test_description}" do
      it context_return_value(desired_test_result) do
        run_test(resource_type, password_property, sub_property_name,
                 test_template_type, test_description, desired_test_result)
      end
    end
  end
end

describe OpsWorksStackRdsDbInstancesDbPasswordRule do
  context 'opswork stack without rds db instances' do
    it 'returns empty list of violations' do
      cfn_model = CfnParser.new.parse read_test_template(
                                        'yaml/opsworks_stack/opsworks_stack_no_rds_db_instances.yaml'
                                      )

      actual_logical_resource_ids = OpsWorksStackRdsDbInstancesDbPasswordRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
