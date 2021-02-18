# frozen_string_literal: true

require 'cfn-nag/util/truthy'
require 'cfn-nag/violation'
require_relative 'base'

class DMSReplicationInstanceNotPublicRule < BaseRule
  def rule_text
    'Database Migration Service replication instances are public, property PubliclyAccessible should be set to false'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W91'
  end

  def audit_impl(cfn_model)
    violating_replications = cfn_model.resources_by_type('AWS::DMS::ReplicationInstance').select do |replication|
      replication.publiclyAccessible.nil? || truthy?(replication.publiclyAccessible)
    end

    violating_domains.map(&:logical_resource_id)
  end
end