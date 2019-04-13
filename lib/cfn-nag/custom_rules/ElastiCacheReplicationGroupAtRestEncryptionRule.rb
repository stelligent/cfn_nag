# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class ElastiCacheReplicationGroupAtRestEncryptionRule < BaseRule
  def rule_text
    'ElastiCache ReplicationGroup should have encryption enabled for at rest'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F25'
  end

  def audit_impl(cfn_model)
    resources = cfn_model.resources_by_type('AWS::ElastiCache::ReplicationGroup')

    violating_groups = resources.select do |group|
      group.atRestEncryptionEnabled.nil? ||
        group.atRestEncryptionEnabled.to_s.casecmp('false').zero?
    end

    violating_groups.map(&:logical_resource_id)
  end
end
