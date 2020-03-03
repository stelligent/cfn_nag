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
    'W60'
  end

  def audit_impl(cfn_model)
    violating_vpcs = cfn_model.resources_by_type('AWS::EC2::VPC')
                              .select do |vpc|
      flowlog_for_vpc(cfn_model, vpc).nil?
    end

    violating_vpcs.map(&:logical_resource_id)
  end

  def flowlog_for_vpc(cfn_model, vpc)
    cfn_model.resources_by_type('AWS::EC2::FlowLog').find do |flowlog|
      if flowlog.resourceId && flowlog.resourceId['Ref']
        flowlog.resourceId['Ref'] == vpc.logical_resource_id
      end
    end
  end
end
