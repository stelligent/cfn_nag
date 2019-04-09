# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class EbsVolumeHasSseRule < BaseRule
  def rule_text
    'EBS volume should have server-side encryption enabled'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F1'
  end

  def audit_impl(cfn_model)
    violating_volumes = cfn_model.resources_by_type('AWS::EC2::Volume')
                                 .select do |volume|
      volume.encrypted.nil? || volume.encrypted.to_s.casecmp('false').zero?
    end

    violating_volumes.map(&:logical_resource_id)
  end
end
