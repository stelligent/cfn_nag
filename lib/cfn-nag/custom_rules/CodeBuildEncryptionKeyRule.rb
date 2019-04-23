# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

# Rule class to warn on CodeBuild::Project without an EncryptionKey specified
class CodeBuildEncryptionKeyRule < BaseRule
  def rule_text
    'CodeBuild project should specify an EncryptionKey value'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W32'
  end

  def audit_impl(cfn_model)
    violating_projects = cfn_model.resources_by_type('AWS::CodeBuild::Project')
                                  .select do |project|
      project.encryptionKey.nil?
    end

    violating_projects.map(&:logical_resource_id)
  end
end
