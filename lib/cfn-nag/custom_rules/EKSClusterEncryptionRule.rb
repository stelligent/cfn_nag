# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class EKSClusterEncryptionRule < BaseRule
  def rule_text
    'EKS Cluster EncryptionConfig Provider should specify KeyArn to enable Encryption.'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W82'
  end

  def audit_impl(cfn_model)
    violating_clusters = cfn_model.resources_by_type('AWS::EKS::Cluster').select do |cluster|
      if cluster.encryptionConfig.nil? || violating_configs?(cluster)
        true
      else
        violating_providers?(cluster)
      end
    end

    violating_clusters.map(&:logical_resource_id)
  end

  private

  def violating_configs?(cluster)
    violating_config = cluster.encryptionConfig.select do |config|
      config['Provider'].nil?
    end
    !violating_config.empty?
  end

  def violating_providers?(cluster)
    violating_provider = cluster.encryptionConfig.select do |config|
      config['Provider']['KeyArn'].empty?
    end
    !violating_provider.empty?
  end
end
