# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class EbsVolumeEncryptionKeyRule < BaseRule
  def rule_text
    'EBS Volume should specify a KmsKeyId value'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W37'
  end

  def audit_impl(cfn_model)
    violating_volumes = cfn_model.resources_by_type('AWS::EC2::Volume')
                                 .select do |volume|
      volume.kmsKeyId.nil? || volume.kmsKeyId == { 'Ref' => 'AWS::NoValue' }
    end

    violating_volumes.map(&:logical_resource_id)
  end
end
