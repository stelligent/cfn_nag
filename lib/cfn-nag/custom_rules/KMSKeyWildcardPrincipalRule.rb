# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class KMSKeyWildcardPrincipalRule < BaseRule
  def rule_text
    'KMS key should not allow * principal'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W55'
  end

  def audit_impl(cfn_model)
    # Select all AWS::KMS::Key resources to audit
    violating_keys = cfn_model.resources_by_type('AWS::KMS::Key').select do |key|
      # Select all key policy 'Statement' objects to audit
      violating_statements = key.keyPolicy['Statement'].select do |statement|
        # Add statement as violating if allowing wildcard principal
        statement['Principal'] == '*' && statement['Effect'] == 'Allow'
      end

      !violating_statements.empty?
    end

    violating_keys.map(&:logical_resource_id)
  end
end
