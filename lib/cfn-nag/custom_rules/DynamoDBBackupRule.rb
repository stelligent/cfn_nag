# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/truthy'
require_relative 'base'

class DynamoDBBackupRule < BaseRule
  def rule_text
    'DynamoDB table should have backup enabled, should be set using PointInTimeRecoveryEnabled'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W78'
  end

  def audit_impl(cfn_model)
    violating_ddb_tables = cfn_model.resources_by_type('AWS::DynamoDB::Table').select do |table|
      table.pointInTimeRecoverySpecification.nil? ||
        !truthy?(table.pointInTimeRecoverySpecification['PointInTimeRecoveryEnabled'].to_s)
    end

    violating_ddb_tables.map(&:logical_resource_id)
  end
end
