# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class RDSInstanceBackupRetentionPeriodRule < BaseRule
  def rule_text
    'RDS instance should have backup retention period greater than 0'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W75'
  end

  def audit_impl(cfn_model)
    rds_dbinstances = cfn_model.resources_by_type('AWS::RDS::DBInstance')

    violating_rdsinstances = rds_dbinstances.select do |instance|
      instance.backupRetentionPeriod && instance.backupRetentionPeriod == 0
    end

    violating_rdsinstances.map(&:logical_resource_id)
  end
end
