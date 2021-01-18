# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/truthy'
require_relative 'base'

class DAXClusterEncryptionRule < BaseRule
  def rule_text
    'DynamoDB Accelerator (DAX) Cluster should have encryption enabled'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W83'
  end

  def audit_impl(cfn_model)
    violating_clusters = cfn_model.resources_by_type('AWS::DAX::Cluster').select do |cluster|
      cluster.sSESpecification.nil? || !truthy?(cluster.sSESpecification['SSEEnabled'].to_s)
    end

    violating_clusters.map(&:logical_resource_id)
  end
end
