# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/truthy'
require_relative 'base'

class RDSInstanceDeletionProtectionRule < BaseRule
  def rule_text
    'RDS instance should have deletion protection enabled'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F80'
  end

  def audit_impl(cfn_model)
    rds_dbinstances = cfn_model.resources_by_type('AWS::RDS::DBInstance')

    violating_rdsinstances = rds_dbinstances.select do |instance|
      instance.deletionProtection.nil? || !truthy?(instance.deletionProtection.to_s)
    end

    violating_rdsinstances.map(&:logical_resource_id)
  end
end
