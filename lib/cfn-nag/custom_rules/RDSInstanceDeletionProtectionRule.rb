# frozen_string_literal: true

require_relative 'base'
require 'cfn-nag/util/truthy'
require 'cfn-nag/violation'

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
      not_protected?(instance) && !aurora?(instance)
    end

    violating_rdsinstances.map(&:logical_resource_id)
  end

  private

  def not_protected?(instance)
    not_truthy?(instance.deletionProtection) || instance.deletionProtection == { 'Ref' => 'AWS::NoValue' }
  end

  def aurora?(db_instance)
    aurora_engines = %w[
      aurora
      aurora-mysql
      aurora-postgresql
    ]
    aurora_engines.include? db_instance.engine
  end
end
