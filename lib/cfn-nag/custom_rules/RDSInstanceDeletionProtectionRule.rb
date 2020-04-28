# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'boolean_base_rule'

class RDSInstanceDeletionProtectionRule < BooleanBaseRule
  def rule_text
    'RDS instance should have deletion protection enabled'
  end

  def resource_type
    'AWS::RDS::DBInstance'
  end

  def boolean_property
    :deletionProtection
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F80'
  end
end
