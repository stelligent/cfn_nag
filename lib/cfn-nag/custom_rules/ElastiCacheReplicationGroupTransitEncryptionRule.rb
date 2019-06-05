# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'boolean_base_rule'

class ElastiCacheReplicationGroupTransitEncryptionRule < BooleanBaseRule
  def rule_text
    'ElastiCache ReplicationGroup should have encryption enabled for in transit'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F33'
  end

  def resource_type
    'AWS::ElastiCache::ReplicationGroup'
  end

  def boolean_property
    :transitEncryptionEnabled
  end
end
