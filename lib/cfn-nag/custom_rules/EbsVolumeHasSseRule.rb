# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'boolean_base_rule'

class EbsVolumeHasSseRule < BooleanBaseRule
  def rule_text
    'EBS volume should have server-side encryption enabled'
  end

  def resource_type
    'AWS::EC2::Volume'
  end

  def boolean_property
    :encrypted
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F1'
  end
end
