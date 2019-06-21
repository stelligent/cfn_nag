# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/enforce_reference_parameter'
require 'cfn-nag/util/enforce_string_or_dynamic_reference'
require_relative 'base'

class RedshiftClusterMasterUserPasswordRule < BaseRule
  def rule_text
    'Redshift Cluster master user password must be Ref to NoEcho Parameter. ' \
    'Default credentials are not recommended'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F35'
  end

  def audit_impl(cfn_model)
    redshift_clusters = cfn_model.resources_by_type('AWS::Redshift::Cluster')
    violating_redshift_clusters = redshift_clusters.select do |cluster|
      if cluster.masterUserPassword.nil?
        false
      else
        insecure_parameter?(cfn_model, cluster.masterUserPassword) ||
          insecure_string_or_dynamic_reference?(cfn_model, cluster.masterUserPassword)
      end
    end

    violating_redshift_clusters.map(&:logical_resource_id)
  end
end
