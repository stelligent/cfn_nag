# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/enforce_noecho_parameter.rb'
require 'cfn-nag/util/enforce_dynamic_reference.rb'
require 'cfn-nag/util/truthy.rb'
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
        conditional_is_invalid?(cfn_model, cluster)
      else
        password_is_invalid?(cfn_model, cluster.masterUserPassword)
      end
    end

    violating_rdsclusters.map(&:logical_resource_id)
  end

  private

  def determine_reference_name(cfn_model, cluster)
    conditions = cfn_model.raw_model['Conditions']
    condition = cluster.masterUserPassword['Fn::If'][0]

    if conditions[condition].class == Array
      conditions[condition].first['Ref']
    else
      conditions[condition]['Fn::Equals'].first['Ref']
    end
  end

  def parse_conditional_values(cfn_model, cluster)
    ref = determine_reference_name(cfn_model, cluster)
    parameter_value =
      cfn_model.parameters[ref].synthesized_value ||=
        cfn_model.parameters[ref].default
    password_true = cluster.masterUserPassword['Fn::If'][1]
    password_false = cluster.masterUserPassword['Fn::If'][2]

    [password_true, password_false, parameter_value]
  end

  def conditional_is_invalid?(cfn_model, cluster)
    password_true, password_false, parameter_value = parse_conditional_values(cfn_model, cluster)

    if truthy?(parameter_value)
      conditional_password_is_invalid?(cfn_model, password_true, cluster.snapshotIdentifier)
    else
      conditional_password_is_invalid?(cfn_model, password_false, cluster.snapshotIdentifier)
    end
  end

  def password_is_invalid?(cfn_model, password)
    !no_echo_parameter_without_default?(cfn_model, password) &&
      !dynamic_reference_property_value?(cfn_model, password)
  end

  def conditional_password_is_invalid?(cfn_model, password, snapshot_identifier)
    (!snapshot_identifier.nil? &&
      password != { 'Ref' => 'AWS::NoValue' }) &&
      password_is_invalid?(cfn_model, password)
  end
end
