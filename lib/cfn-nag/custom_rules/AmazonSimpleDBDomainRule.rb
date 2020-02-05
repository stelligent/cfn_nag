# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'resource_base_rule'

class AmazonSimpleDBDomainRule < ResourceBaseRule
  def rule_text
    'SimpleDB Domain should not be a declared resource'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F77'
  end

  def resource_type
    'AWS::SDB::Domain'
  end
end
