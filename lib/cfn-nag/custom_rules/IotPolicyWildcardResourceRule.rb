# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'
require 'json'


class IotPolicyWildcardResourceRule < BaseRule
  def rule_text
    'IoT policy should not allow * resource'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'W39'
  end

  def audit_impl(cfn_model)

    violating_policies = cfn_model.resources_by_type('AWS::IoT::Policy').select do |policy|

      # there is no support for AWS::IoT::Policy in cfn_model yet, so must 
      # call PolicyDocumentParser ourselves
      policy.policy_document = PolicyDocumentParser.new.parse(policy.policyDocument)

     !policy.policy_document.wildcard_allowed_resources.empty?
    end

    violating_policies.map(&:logical_resource_id)
  end
end
