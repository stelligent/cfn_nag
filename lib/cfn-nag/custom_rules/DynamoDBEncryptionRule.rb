# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/truthy'
require_relative 'base'

class DynamoDBEncryptionRule < BaseRule
  def rule_text
    'DynamoDB table should have encryption enabled using a CMK stored in KMS'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W74'
  end

  def audit_impl(cfn_model)
    violating_ddb_tables = cfn_model.resources_by_type('AWS::DynamoDB::Table').select do |table|
      table.sSESpecification.nil? || !truthy?(table.sSESpecification['SSEEnabled'].to_s)
    end

    violating_ddb_tables.map(&:logical_resource_id)
  end
end
