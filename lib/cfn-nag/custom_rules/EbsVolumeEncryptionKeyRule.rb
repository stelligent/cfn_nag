# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'boolean_base_rule'

class EbsVolumeEncryptionKeyRule < BooleanBaseRule
  def rule_text
    'EBS Volume should specify a KmsKeyId value'
  end

  def resource_type
    'AWS::EC2::Volume'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W37'
  end

  def boolean_property
    :kmsKeyId
  end
end
