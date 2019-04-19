# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class NeptuneDBClusterStorageEncryptedRule < BaseRule
  def rule_text
    'Neptune database cluster storage should have encryption enabled'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F30'
  end

  def audit_impl(cfn_model)
    resources = cfn_model.resources_by_type('AWS::Neptune::DBCluster')

    violating_storage = resources.select do |filesystem|
      filesystem.storageEncrypted.nil? ||
        filesystem.storageEncrypted.to_s.casecmp('false').zero?
    end

    violating_storage.map(&:logical_resource_id)
  end
end
