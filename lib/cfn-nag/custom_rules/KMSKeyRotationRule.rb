# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class KMSKeyRotationRule < BaseRule
  def rule_text
    'EnableKeyRotation should not be false or absent on KMS::Key resource'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F19'
  end

  def audit_impl(cfn_model)
    violating_keys = cfn_model.resources_by_type('AWS::KMS::Key')
                              .select do |key|
      key_rotation_false_or_absent?(key)
    end

    violating_keys.map(&:logical_resource_id)
  end

  private

  def key_rotation_false_or_absent?(resource)
    !truthy?(resource.enableKeyRotation)
  end
end
