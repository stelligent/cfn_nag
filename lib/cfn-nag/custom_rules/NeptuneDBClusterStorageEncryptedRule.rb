# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'boolean_base_rule'

class NeptuneDBClusterStorageEncryptedRule < BooleanBaseRule
  def rule_text
    'Neptune database cluster storage should have encryption enabled'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F30'
  end

  def resource_type
    'AWS::Neptune::DBCluster'
  end

  def boolean_property
    :storageEncrypted
  end
end
