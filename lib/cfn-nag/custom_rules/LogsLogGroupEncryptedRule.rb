# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/truthy'
require_relative 'base'

class LogsLogGroupEncryptedRule < BaseRule
  def rule_text
    'CloudWatchLogs LogGroup should specify a KMS Key Id to encrypt the log data'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W84'
  end

  def audit_impl(cfn_model)
    violating_groups = cfn_model.resources_by_type('AWS::Logs::LogGroup').select do |group|
      group.kmsKeyId.nil?
    end

    violating_groups.map(&:logical_resource_id)
  end
end
