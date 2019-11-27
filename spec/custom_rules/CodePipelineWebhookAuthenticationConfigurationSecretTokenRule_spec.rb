require 'spec_helper'
require 'password_rule_spec_helper'
require 'cfn-model'

resource_type = 'AWS::CodePipeline::Webhook'
password_property = 'AuthenticationConfiguration'
sub_property_name = 'SecretToken'
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
