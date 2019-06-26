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
# example: rule_name = 'RedshiftClusterMasterUserPasswordRule'
def rule_name
  name_scheme = resource_type.sub('AWS', '').gsub('::', '')
  calculated_rule_name = name_scheme + password_property + 'Rule'
  calculated_rule_name
end

# Creates the file prefix based on the 'test_template_type' and 'resource_name'
# provided. 
# example: test_template_type = 'yaml'
# example: resource_type = 'AWS::Redshift::Cluster'
# example: file_path_prefix = 'yaml/redshift_cluster/redshift_cluster_'
def file_path_prefix
  resource_name = resource_type.sub('AWS::', '').gsub('::', '_').downcase
  path_prefix = test_template_type + '/' + resource_name + '/' + resource_name + '_'
  path_prefix
end

# AWS Resource Name
# example: resource_type = 'AWS::Redshift::Cluster'
# example: resource_name = 'Redshift Cluster'
def resource_name
  resource_type.sub('AWS::', '').gsub('::', ' ')
end

# Name of Resource ID used in CloudFormation Template
# This is calculated based off of the 'resource_type', so you will need to ensure
# that the test templates that you create match this name
# example: resource_type = AWS::Redshift::Cluster
# example: template_resource_id = 'RedshiftCluster'
def template_resource_id
  resource_type.sub('AWS::', '').gsub('::', '')
end

# Creates snakecase for 'password_property'
# example: password_property = 'MasterUserPassword'
# example: property_snake_case = 'master_user_password'
def property_snake_case
  password_property.gsub(/(?<=[a-z])(?=[A-Z])/, ' ').gsub(' ', '_').downcase
end

def returns_violation
  'returns offending logical resource id'
end

def returns_not_violation
  'returns empty list'
end

describe rule_name, :rule do
  context resource_name + ' without ' + password_property + ' set' do
    it returns_not_violation do
      cfn_model = CfnParser.new.parse read_test_template(
        file_path_prefix + 'no_' + property_snake_case + '.yml'
      )

      actual_logical_resource_ids =
        Object.const_get(rule_name).new.audit_impl cfn_model
      expected_logical_resource_ids = []

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context resource_name + ' with parameter ' + password_property + ' with NoEcho' do
    it returns_not_violation do
      cfn_model = CfnParser.new.parse read_test_template(
        file_path_prefix + property_snake_case + '_parameter_noecho.yml'
      )

      actual_logical_resource_ids =
        Object.const_get(rule_name).new.audit_impl cfn_model
      expected_logical_resource_ids = []

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context resource_name + ' with literal ' + password_property + ' in plaintext' do
    it returns_violation do
      cfn_model = CfnParser.new.parse read_test_template(
        file_path_prefix + property_snake_case + '_plaintext.yml'
      )

      actual_logical_resource_ids =
        Object.const_get(rule_name).new.audit_impl cfn_model
      expected_logical_resource_ids = [template_resource_id]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context resource_name + ' with parameter ' + password_property + ' with NoEcho ' \
    'that has Default value' do
    it returns_violation do
      cfn_model = CfnParser.new.parse read_test_template(
        file_path_prefix + property_snake_case + '_parameter_noecho_with_default.yml'
      )
      actual_logical_resource_ids =
        Object.const_get(rule_name).new.audit_impl cfn_model
      expected_logical_resource_ids = [template_resource_id]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context resource_name + ' ' + password_property + ' from Secrets Manager' do
    it returns_not_violation do
      cfn_model = CfnParser.new.parse read_test_template(
        file_path_prefix + property_snake_case + '_secrets_manager.yml'
      )
      actual_logical_resource_ids =
        Object.const_get(rule_name).new.audit_impl cfn_model
      expected_logical_resource_ids = []

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context resource_name + ' ' + password_property + ' from Secure Systems Manager' do
    it returns_not_violation do
      cfn_model = CfnParser.new.parse read_test_template(
        file_path_prefix + property_snake_case + '_ssm-secure.yml'
      )
      actual_logical_resource_ids =
        Object.const_get(rule_name).new.audit_impl cfn_model
      expected_logical_resource_ids = []

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context resource_name + ' ' + password_property + ' from Systems Manager' do
    it returns_violation do
      cfn_model = CfnParser.new.parse read_test_template(
        file_path_prefix + property_snake_case + '_ssm.yml'
      )
      actual_logical_resource_ids =
        Object.const_get(rule_name).new.audit_impl cfn_model
      expected_logical_resource_ids = [template_resource_id]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
