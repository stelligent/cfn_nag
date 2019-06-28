require 'spec_helper'
require 'password_rule_spec_helper'
require 'cfn-model'

password_property = 'MasterUserPassword'
resource_type = 'AWS::RDS::DBCluster'
test_template_type = 'yaml'
class_name = rule_name(resource_type, password_property)

require "cfn-nag/custom_rules/#{class_name}"

describe Object.const_get(class_name), :rule do
  password_rule_test_sets.each do |test_description, desired_test_result|
    context "#{resource_type} #{password_property} #{test_description}" do
      it context_return_value(desired_test_result) do
        run_test(resource_type, password_property, test_template_type,
                 test_description, desired_test_result)
      end
    end
  end
end
