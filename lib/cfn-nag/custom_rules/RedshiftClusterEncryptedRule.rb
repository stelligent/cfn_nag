# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'boolean_base_rule'

class RedshiftClusterEncryptedRule < BooleanBaseRule
  def rule_text
    'Redshift Cluster should have encryption enabled'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F28'
  end

  def resource_type
    'AWS::Redshift::Cluster'
  end

  def boolean_property
    :encrypted
  end
end
