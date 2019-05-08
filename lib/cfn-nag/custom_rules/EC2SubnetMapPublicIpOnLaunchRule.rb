# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class EC2SubnetMapPublicIpOnLaunchRule < BaseRule
  def rule_text
    'EC2 Subnet should not have MapPublicIpOnLaunch set to true'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W33'
  end

  def audit_impl(cfn_model)
    violating_subnets = cfn_model.resources_by_type('AWS::EC2::Subnet')
                                 .select do |subnet|
      truthy?(subnet.mapPublicIpOnLaunch)
    end

    violating_subnets.map(&:logical_resource_id)
  end
end
