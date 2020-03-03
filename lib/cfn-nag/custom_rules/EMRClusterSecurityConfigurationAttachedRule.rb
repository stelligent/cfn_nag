# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class EMRClusterSecurityConfigurationAttachedRule < BaseRule
  def rule_text
    'EMR Cluster should specify SecurityConfiguration.'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W63'
  end

  def audit_impl(cfn_model)
    violating_emr_clusters = cfn_model.resources_by_type('AWS::EMR::Cluster').select do |cluster|
      # Warn if SecurityConfiguration property is not set or does not exist in this template
      cluster.securityConfiguration.nil? || cfn_model.resource_by_ref(cluster.securityConfiguration, 'Arn').nil?
    end

    violating_emr_clusters.map(&:logical_resource_id)
  end
end
