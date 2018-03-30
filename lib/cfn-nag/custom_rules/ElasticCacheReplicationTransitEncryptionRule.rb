require 'cfn-nag/violation'
require_relative 'base'

class ElasticCacheReplicationTransitEncryptionRule< BaseRule
  def rule_text
    'Elastic Cache should have encryption in transit enabled '
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W26'
  end

  def audit_impl(cfn_model)
    violating_groups = \
      cfn_model.resources_by_type('AWS::ElasticCache::ReplicationGroup')
               .select do |replicationgroup|
        replicationgroup.transitEncryptionEnabled.nil? ||
          replicationgroup.transitEncryptionEnabled['Enabled'] != true
      end

    violating_groups.map(&:logical_resource_id)
  end
end
