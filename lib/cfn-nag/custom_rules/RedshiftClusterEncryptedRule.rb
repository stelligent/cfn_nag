# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class RedshiftClusterEncryptedRule < BaseRule
  def rule_text
    'Redshift Cluster should have encryption enabled'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F28'
  end

  def audit_impl(cfn_model)
    resources = cfn_model.resources_by_type('AWS::Redshift::Cluster')

    violating_clusters = resources.select do |cluster|
      cluster.encrypted.nil? ||
        cluster.encrypted.to_s.casecmp('false').zero?
    end

    violating_clusters.map(&:logical_resource_id)
  end
end
