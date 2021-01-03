require 'spec_helper'
require 'password_rule_spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/EKSClusterEncryptionRule'

describe EKSClusterEncryptionRule do
  context 'EKS Cluster with no EncryptionConfig' do
    it 'Returns the logical resource ID of the offending EKS Cluster resource' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/eks_cluster/eks_cluster_encryptionconfig_not_set.yaml'
      )

      actual_logical_resource_ids =
        EKSClusterEncryptionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[EKSCluster]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'EKS Cluster with EncryptionConfig Provider KeyArn set' do
    it 'Returns empty list' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/eks_cluster/eks_cluster_encryptionconfig_provider_keyarn_set.yaml'
      )

      actual_logical_resource_ids =
        EKSClusterEncryptionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'EKS Cluster EncryptionConfig with Provider not set' do
    it 'Returns the logical resource ID of the offending EKS Cluster resource' do
      cfn_model = CfnParser.new.parse read_test_template(
        'yaml/eks_cluster/eks_cluster_encryptionconfig_provider_not_set.yaml'
      )

      actual_logical_resource_ids =
        EKSClusterEncryptionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[EKSCluster]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
