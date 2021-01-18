# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/truthy'
require_relative 'base'

class DLMLifecyclePolicyCrossRegionCopyEncryptionRule < BaseRule
  def rule_text
    'DLM LifecyclePolicy PolicyDetails Actions CrossRegionCopy EncryptionConfiguration should enable Encryption'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W81'
  end

  def audit_impl(cfn_model)
    violating_policies = cfn_model.resources_by_type('AWS::DLM::LifecyclePolicy').select do |policy|
      if policy.policyDetails['Actions'].nil?
        false
      else
        violating_actions = policy.policyDetails['Actions'].select do |action|
          violating_copies = action['CrossRegionCopy'].select do |copy|
            !truthy?(copy['EncryptionConfiguration']['Encrypted'].to_s)
          end
          !violating_copies.empty?
        end
        !violating_actions.empty?
      end
    end

    violating_policies.map(&:logical_resource_id)
  end
end
