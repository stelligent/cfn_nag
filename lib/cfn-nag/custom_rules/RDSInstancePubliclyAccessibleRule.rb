# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class RDSInstancePubliclyAccessibleRule < BaseRule
  def rule_text
    'RDS instance should not be publicly accessible'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F22'
  end

  def audit_impl(cfn_model)
    violating_rdsinstances = cfn_model.resources_by_type('AWS::RDS::DBInstance').select do |instance|
      instance.publiclyAccessible.nil? || instance.publiclyAccessible.to_s.casecmp('true').zero?
    end

    violating_rdsinstances.map(&:logical_resource_id)
  end
end
