# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'boolean_base_rule'

class RDSDBClusterStorageEncryptedRule < BooleanBaseRule
  def rule_text
    'RDS DBCluster should have StorageEncrypted enabled'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F26'
  end

  def resource_type
    'AWS::RDS::DBCluster'
  end

  def boolean_property
    :storageEncrypted
  end
end
