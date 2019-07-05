# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'boolean_base_rule'

class EBSEncryptionRule < BooleanBaseRule
  def rule_text
    'EBS Volume should use true for property encryption'
  end
  
  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F38'
  end

  def resource_type
    'AWS::EC2::Volume'
  end

  def boolean_property
    :encrypted
  end

end
