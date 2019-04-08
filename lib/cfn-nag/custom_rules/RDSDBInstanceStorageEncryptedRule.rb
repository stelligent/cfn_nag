require 'cfn-nag/violation'
require_relative 'base'

class RDSDBInstanceStorageEncryptedRule < BaseRule
  def rule_text
    'RDS DBInstance should have StorageEncrypted enabled'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F27'
  end

  def audit_impl(cfn_model)
    resources = cfn_model.resources_by_type('AWS::RDS::DBInstance')

    violating_instances = resources.select do |instance|
      instance.storageEncrypted.nil? ||
        instance.storageEncrypted.to_s.casecmp('false').zero?
    end

    violating_instances.map(&:logical_resource_id)
  end
end
