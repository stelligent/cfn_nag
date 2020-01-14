# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class KMSKeyWildcardPrincipalRule < BaseRule
  def rule_text
    'KMS key should not allow * principal ' \
    '(https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html)'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F76'
  end

  def audit_impl(cfn_model)
    # Select all AWS::KMS::Key resources to audit
    violating_keys = cfn_model.resources_by_type('AWS::KMS::Key').select do |key|
      # Return key if wildcard_allowed_principals boolean is not empty
      !key.key_policy.policy_document.wildcard_allowed_principals.empty?
    end

    violating_keys.map(&:logical_resource_id)
  end
end
