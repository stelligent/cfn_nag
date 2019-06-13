# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/enforce_noecho_parameter.rb'
require 'cfn-nag/util/enforce_secrets_manager.rb'
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
        conditions = cfn_model.raw_model['Conditions']
        condition = cluster.masterUserPassword['Fn::If'][0]
        ref =
          if conditions[condition].class == Array
            conditions[condition].first['Ref']
          else
            conditions[condition]['Fn::Equals'].first['Ref']
          end
        parameter_value =
          cfn_model.parameters[ref].synthesized_value ||=
            cfn_model.parameters[ref].default
        password_true = cluster.masterUserPassword['Fn::If'][1]
        password_false = cluster.masterUserPassword['Fn::If'][2]

        if truthy?(parameter_value)
          (!cluster.snapshotIdentifier.nil? &&
            !no_value?(password_true)) &&
            password_is_invalid?(cfn_model, password_true)
        else
          (!cluster.snapshotIdentifier.nil? &&
            !no_value?(password_false)) &&
            password_is_invalid?(cfn_model, password_false)
        end
      else
        password_is_invalid?(cfn_model, cluster.masterUserPassword)
      end
    end

    violating_rdsclusters.map(&:logical_resource_id)
  end

  private

  def password_is_invalid?(cfn_model, password)
    !no_echo_parameter_without_default?(cfn_model, password) &&
      !secrets_manager_property_value?(cfn_model, password)
  end

  def no_value?(password)
    password == { 'Ref' => 'AWS::NoValue' }
  end
end
