# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class VpcHasFlowLogRule < BaseRule
  def rule_text
    'VPC should have a flow log attached'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W58'
  end

  def audit_impl(cfn_model)
    violating_policies = cfn_model.resources_by_type('AWS::EC2::VPC')
                                  .select do
      cfn_model.resources_by_type('AWS::EC2::FlowLog').empty?
    end

    violating_policies.map(&:logical_resource_id)
  end
end
