# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class DynamoDBBillingModeRule < BaseRule
  def rule_text
    'DynamoDB table should have billing mode set to either PAY_PER_REQUEST or PROVISIONED'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W73'
  end

  def audit_impl(cfn_model)
    violating_ddb_tables = cfn_model.resources_by_type('AWS::DynamoDB::Table').select do |table|
      table.billingMode.nil? || (table.billingMode != 'PAY_PER_REQUEST' && table.billingMode != 'PROVISIONED')
    end

    violating_ddb_tables.map(&:logical_resource_id)
  end
end
