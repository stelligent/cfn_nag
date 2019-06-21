# frozen_string_literal: true

require 'cfn-nag/violation'
require 'cfn-nag/util/enforce_reference_parameter'
require 'cfn-nag/util/enforce_string_or_dynamic_reference'
require_relative 'base'

class DMSEndpointPasswordRule < BaseRule
  def rule_text
    'DMS Endpoint password must be Ref to NoEcho Parameter. ' \
    'Default credentials are not recommended'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F37'
  end

  def audit_impl(cfn_model)
    dms_endpoints = cfn_model.resources_by_type('AWS::DMS::Endpoint')
    violating_dms_endpoints = dms_endpoints.select do |endpoint|
      if endpoint.password.nil?
        false
      else
        insecure_parameter?(cfn_model, endpoint.password) ||
          insecure_string_or_dynamic_reference?(cfn_model, endpoint.password)
      end
    end

    violating_dms_endpoints.map(&:logical_resource_id)
  end
end
