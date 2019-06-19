# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/enforce_dynamic_reference.rb'
require 'cfn-nag/util/enforce_reference_parameter.rb'
require_relative 'base'

class RDSDBClusterMasterUserPasswordRule < BaseRule
  def rule_text
    'RDS DB Cluster master user password must be Ref to NoEcho Parameter. ' \
    'Default credentials are not recommended'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F34'
  end

  def audit_impl(cfn_model)
    rds_dbclusters = cfn_model.resources_by_type('AWS::RDS::DBCluster')
    violating_rdsclusters = rds_dbclusters.select do |cluster|
      if cluster.masterUserPassword.nil?
        false
      else
        insecure_parameter?(cfn_model, cluster.masterUserPassword) ||
          insecure_dynamic_reference?(cfn_model, cluster.masterUserPassword)
      end
    end

    violating_rdsclusters.map(&:logical_resource_id)
  end
end
