# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class WorkspacesWorkspaceEncryptionRule < BaseRule
  def rule_text
    'Workspace should have encryption enabled'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F29'
  end

  def audit_impl(cfn_model)
    resources = cfn_model.resources_by_type('AWS::WorkSpaces::Workspace')

    violating_workspaces = resources.select do |workspace|
      workspace.userVolumeEncryptionEnabled.nil? ||
        workspace.userVolumeEncryptionEnabled.to_s.casecmp('false').zero?
    end

    violating_workspaces.map(&:logical_resource_id)
  end
end
