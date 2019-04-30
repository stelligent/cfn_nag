require 'spec_helper'
require 'cfn-nag/custom_rules/ResourceWithExplicitNameRule'
require 'cfn-model'

describe ResourceWithExplicitNameRule do
  describe 'AWS::ApiGateway::ApiKey' do
    context 'when an explicit name is provided' do
      it 'returns an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/apigateway_apikey/apikey_with_explicit_name.json')
        actual_logical_resource_ids = ResourceWithExplicitNameRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq ['ApiKeyWithName']
      end
    end
    context 'when an explicit name is not provided' do
      it 'does not return a logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/apigateway_apikey/apikey_without_explicit_name.json')
        actual_logical_resource_ids = ResourceWithExplicitNameRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end
  end
  describe 'AWS::CodeDeploy::DeploymentConfig' do
    context 'when an explicit name is provided' do
      it 'returns an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/codedeploy_deploymentconfig/deployment_config_with_explicit_name.json')
        actual_logical_resource_ids = ResourceWithExplicitNameRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq ['DeployConfigWithName']
      end
    end

    context 'when an explicit name is not provided' do
      it 'does not return a logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/codedeploy_deploymentconfig/deployment_config_without_explicit_name.json')
        actual_logical_resource_ids = ResourceWithExplicitNameRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end
  end
  describe 'AWS::IAM::DeploymentGroup' do
    context 'when an explicit name is provided' do
      it 'returns an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/codedeploy_deploymentgroup/deployment_group_with_explicit_name.json')
        actual_logical_resource_ids = ResourceWithExplicitNameRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq ['DeploymentGroupWithName']
      end
    end
    context 'when an explicit name is not provided' do
      it 'does not return a logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/codedeploy_deploymentgroup/deployment_group_without_explicit_name.json')
        actual_logical_resource_ids = ResourceWithExplicitNameRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end
  end
  describe 'AWS::Elasticsearch::Domain' do
    context 'when an explicit name is provided' do
      it 'returns an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/elasticsearch/elasticsearch_domain_with_explicit_name.json')
        actual_logical_resource_ids = ResourceWithExplicitNameRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq ['ElasticsearchDomainWithName']
      end
    end
    context 'when an explicit name is not provided' do
      it 'does not return an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/elasticsearch/elasticsearch_domain_without_explicit_name.json')
        actual_logical_resource_ids = ResourceWithExplicitNameRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end
  end
  describe 'AWS::IAM::Role' do
    context 'when an explicit name is provided' do
      it 'returns offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/iam_role/iam_role_with_explicit_name.json')
        actual_logical_resource_ids = ResourceWithExplicitNameRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq ['RoleWithName']
      end
    end

    context 'when an explicit name is provided as an empty string' do
      it 'returns offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/iam_role/iam_role_with_explicit_name_empty_string.json')
        actual_logical_resource_ids = ResourceWithExplicitNameRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq ['RoleWithEmptyName']
      end
    end

    context 'when an explicit name is not provided' do
      it 'does not return a logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/iam_role/iam_role_without_explicit_name.json')
        actual_logical_resource_ids = ResourceWithExplicitNameRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end
  end

  describe 'AWS::IAM::Group' do
    context 'when an explicit name is provided' do
      it 'returns an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/iam_group/iam_group_with_explicit_name.json')
        actual_logical_resource_ids = ResourceWithExplicitNameRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq ['GroupWithName']
      end
    end

    context 'when an explicit name is not provided' do
      it 'does not return an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/iam_group/iam_group_without_explicit_name.json')
        actual_logical_resource_ids = ResourceWithExplicitNameRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end
  end

  describe 'AWS::IAM::ManagedPolicy' do
    context 'when an explicit name is provided' do
      it 'returns an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/iam_managed_policy/iam_managed_policy_with_explicit_name.json')
        actual_logical_resource_ids = ResourceWithExplicitNameRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq ['DBPolicyWithName']
      end
    end

    context 'when an explicit name is not provided' do
      it 'does not return an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/iam_managed_policy/iam_managed_policy_without_explicit_name.json')
        actual_logical_resource_ids = ResourceWithExplicitNameRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end
  end

  describe 'AWS::EC2::SecurityGroup' do
    context 'when an explicit name is provided' do
      it 'returns offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/security_group/security_group_with_explicit_name.json')
        actual_logical_resource_ids = ResourceWithExplicitNameRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq ['sgWithName']
      end
    end

    context 'when an explicit name is not provided' do
      it 'does not return a logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/security_group/security_group_without_explicit_name.json')
        actual_logical_resource_ids = ResourceWithExplicitNameRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end
  end

  describe 'AWS::ElasticLoadBalancingV2::LoadBalancer' do
    context 'when an explicit name is provided' do
      it 'returns an offending logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/elasticloadbalancing_loadbalancer/load_balancer_with_explicit_name.json')
        actual_logical_resource_ids = ResourceWithExplicitNameRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq ['LoadBalancerWithName']
      end
    end

    context 'when an explicit name is not provided' do
      it 'does not return a logical resource id' do
        cfn_model = CfnParser.new.parse read_test_template('json/elasticloadbalancing_loadbalancer/load_balancer_without_explicit_name.json')
        actual_logical_resource_ids = ResourceWithExplicitNameRule.new.audit_impl cfn_model

        expect(actual_logical_resource_ids).to eq []
      end
    end
  end
end
