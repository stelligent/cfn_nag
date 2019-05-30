# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class EFSFileSystemEncryptedRule < BaseRule
  def rule_text
    'EFS FileSystem should have encryption enabled'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F32'
  end

  def audit_impl(cfn_model)
    resources = cfn_model.resources_by_type('AWS::EFS::FileSystem')

    violating_filesystems = resources.select do |filesystem|
      filesystem.encrypted.nil? ||
        filesystem.encrypted.to_s.casecmp('false').zero?
    end

    violating_filesystems.map(&:logical_resource_id)
  end
end
