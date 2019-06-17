# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/enforce_noecho_parameter.rb'
require 'cfn-nag/util/enforce_dynamic_reference.rb'
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
      elsif cluster.masterUserPassword.is_a?(Hash) &&
            cluster.masterUserPassword.key?('Fn::If')
      else
        !no_echo_parameter_without_default?(cfn_model,
                                            cluster.masterUserPassword) &&
          !dynamic_reference_property_value?(cfn_model,
                                             cluster.masterUserPassword)
      end
    end

    violating_rdsclusters.map(&:logical_resource_id)
  end
end
