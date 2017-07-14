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
    violating_volumes = cfn_model.resources_by_type('AWS::EC2::Volume').select do |volume|
      volume.encrypted.nil? || volume.encrypted == false
    end

    violating_volumes.map { |violating_user| violating_user.logical_resource_id }
  end
end
