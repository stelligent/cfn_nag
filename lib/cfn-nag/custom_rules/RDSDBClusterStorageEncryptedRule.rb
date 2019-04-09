require 'cfn-nag/violation'
require_relative 'base'

class RDSDBClusterStorageEncryptedRule < BaseRule
  def rule_text
    'RDS DBCluster should have StorageEncrypted enabled'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F26'
  end

  def audit_impl(cfn_model)
    resources = cfn_model.resources_by_type('AWS::RDS::DBCluster')

    violating_clusters = resources.select do |cluster|
      cluster.storageEncrypted.nil? ||
        cluster.storageEncrypted.to_s.casecmp('false').zero?
    end

    violating_clusters.map(&:logical_resource_id)
  end
end
