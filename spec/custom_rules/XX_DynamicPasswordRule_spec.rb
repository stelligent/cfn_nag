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
    'not set': 'fail',
    'parameter with NoEcho': 'pass',
    'parameter with NoEcho and Default value': 'fail',
    'parameter as a literal in plaintext': 'fail',
    'as a literal in plaintext': 'fail',
    'from Secrets Manager': 'pass',
    'from Secure Systems Manager': 'pass',
    'from Systems Manager': 'fail'
  }
end

# Returns a violation or non-violation message based on key/pair value
# from 'test_sets'
def context_return_value(test_sets)
  test_sets.each_pair do |_key, value|
    return returns_violation if value == 'fail'
    return returns_not_violation if value == 'pass'

    raise 'must be pass or fail'
  end
end

# Returns the offending resource id if the test is a violation or it provide
# an empty set if it is a non-violating test based on key/pair value
# from 'test_sets'
def expected_logical_resource_ids(test_sets)
  test_sets.each_pair do |_key, value|
    return [template_resource_id] if value == 'fail'
    return [] if value == 'pass'

    raise 'must be pass or fail'
  end
end

# Creates the full file path string
# example: file_path_prefix = 'yaml/redshift_cluster/redshift_cluster_'
# example: property_snake_case = 'master_user_password'
# example: test_sets.key = 'not set'
# example: test_template_type = 'yaml'
# example result: file_path = 'yaml/redshift_cluster/redshift_cluster_master_user_password_not_set.yaml'
def file_path(test_sets)
  test_sets.each do |_key|
    complete_file_path = file_path_prefix +
                         property_snake_case +
                         test_sets.key.gsub(' ', '_').downcase +
                         '.' +
                         test_template_type

    return complete_file_path
  end
end

# describe rule_name, :rule do
#   context resource_name + password_property + test_sets.key do
#     it context_return_value do
#       cfn_model = CfnParser.new.parse read_test_template(file_path)

#       actual_logical_resource_ids =
#         Object.const_get(rule_name).new.audit_impl cfn_model

#       expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
#     end
#   end
# end
