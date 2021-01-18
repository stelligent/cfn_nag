# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/truthy'
require_relative 'base'

class LogsLogGroupRetentionRule < BaseRule
  def rule_text
    'CloudWatchLogs LogGroup should specify RetentionInDays to expire the log data'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W86'
  end

  def audit_impl(cfn_model)
    violating_groups = cfn_model.resources_by_type('AWS::Logs::LogGroup').select do |group|
      group.retentionInDays.nil?
    end

    violating_groups.map(&:logical_resource_id)
  end
end
