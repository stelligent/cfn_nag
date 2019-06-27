require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/RedshiftClusterMasterUserPasswordRule'

# AWS CloudFormation Resource type name
def resource_type
  'AWS::Redshift::Cluster'
end

# Resource Property name
# Needs to be capitalized and match AWS Docs
def password_property
  'MasterUserPassword'
end

# CloudFormation file type for test templates
# can be 'json' or 'yaml'
def test_template_type
  'yaml'
end

# Creates full combined rule name based on the 'resource_type'
# and'password_property' provided
# It drops the 'AWS::' and '::' from the 'resource_type'
# example: resource_type = 'AWS::Redshift::Cluster'
# example: password_property = 'MasterUserPassword'
# example result: rule_name = 'RedshiftClusterMasterUserPasswordRule'
def rule_name
  name_scheme = resource_type.sub('AWS', '').gsub('::', '')
  calculated_rule_name = name_scheme + password_property + 'Rule'
  calculated_rule_name
end

# Creates the file prefix based on the 'test_template_type' and 'resource_name'
# provided.
# example: test_template_type = 'yaml'
# example: resource_type = 'AWS::Redshift::Cluster'
# example result: file_path_prefix = 'yaml/redshift_cluster/redshift_cluster_'
def file_path_prefix
  resource_name = resource_type.sub('AWS::', '').gsub('::', '_').downcase
  path_prefix = test_template_type +
                '/' +
                resource_name +
                '/' +
                resource_name +
                '_'
  path_prefix
end

# AWS Resource Name
# example: resource_type = 'AWS::Redshift::Cluster'
# example result: resource_name = 'Redshift Cluster'
def resource_name
  resource_type.sub('AWS::', '').gsub('::', ' ')
end

# Name of Resource ID used in CloudFormation Template
# This is calculated based off of the 'resource_type', so you will need to
# ensure that the test templates that you create match this name
# example: resource_type = AWS::Redshift::Cluster
# example result: template_resource_id = 'RedshiftCluster'
def template_resource_id
  resource_type.sub('AWS::', '').gsub('::', '')
end

# Creates snakecase for 'password_property'
# example: password_property = 'MasterUserPassword'
# example result: property_snake_case = 'master_user_password'
def property_snake_case
  password_property.gsub(/(?<=[a-z])(?=[A-Z])/, ' ').gsub(' ', '_').downcase
end

# States that test returns a violation and should provide the offending
# CloudFormation template resource id
def returns_violation
  'returns offending logical resource id'
end

# States that test does not return a violation and should provide
# am empty list
def returns_not_violation
  'returns empty list'
end

# Name of tests to be run and describe if they should pass or fail
# The naming used here will create tests that rely on test files
# created from these keys
def test_sets
  {
    'not set': 'pass',
    'parameter with NoEcho': 'pass',
    'parameter with NoEcho and Default value': 'fail',
    'parameter as a literal in plaintext': 'fail',
    'as a literal in plaintext': 'fail',
    'from Secrets Manager': 'pass',
    'from Secure Systems Manager': 'pass',
    'from Systems Manager': 'fail'
  }
end

describe rule_name, :rule do
  test_sets.each do |test_description, desired_test_result|
    # Creates the context description for the individual spec test
    # Calculated from key provided from 'test_sets'
    context_description = resource_name +
                          ' ' +
                          password_property +
                          ' ' +
                          test_description.to_s

    # Creates the full file path string
    file_path = file_path_prefix +
                property_snake_case +
                '_' +
                test_description.to_s.gsub(' ', '_').downcase +
                '.' +
                test_template_type

    # Set the 'context_return_value' & 'expected_logical_resource_ids'
    # variables based on the value of 'desired_test_result'
    # If 'desired_test_result' is "fail" then we tell it to return the violation
    # message and then we expect to see a resource id
    # If 'desired_test_result' is a "pass" then we tell it to return the
    # non-violation message and then we expect an empty list
    if desired_test_result == 'fail'
      context_return_value = returns_violation
      expected_logical_resource_ids = [template_resource_id]
    elsif desired_test_result == 'pass'
      context_return_value = returns_not_violation
      expected_logical_resource_ids = []
    else
      raise 'needs to be "pass" or "fail"'
    end

    # Spec test
    context context_description do
      it context_return_value do
        cfn_model = CfnParser.new.parse read_test_template(file_path)

        actual_logical_resource_ids =
          Object.const_get(rule_name).new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
      end
    end
  end
end
