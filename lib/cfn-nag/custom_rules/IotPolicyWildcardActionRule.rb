# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'
require 'json'

class IotPolicyWildcardActionRule < BaseRule
  def rule_text
    'IOT policy should not allow * action'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W38'
  end

  def audit_impl(cfn_model)
    violating_policies = cfn_model.resources_by_type('AWS::IoT::Policy').select do |policy|
      policy.policy_document = PolicyDocumentParser.new.parse(cfn_model, policy.policyDocument)
      !policy.policy_document.wildcard_allowed_actions.empty?
    end

    violating_policies.map(&:logical_resource_id)
  end
end
