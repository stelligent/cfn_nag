# frozen_string_literal: true

require 'cfn-nag/violation'
require_relative 'base'

class GameLiftFleetInboundPortRangeRule < BaseRule
  def rule_text
    'GameLift fleet EC2InboundPermissions found with port range instead of just a single port'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W58'
  end

  def audit_impl(cfn_model)
    violating_gamelift_fleets = cfn_model.resources_by_type('AWS::GameLift::Fleet').select do |gamelift_fleet|
      violating_permissions = gamelift_fleet.eC2InboundPermissions.select do |permission|
        # subnet_mask = permission['IpRange'].split('/').length > 1 ? permission['IpRange'].split('/')[1].to_i : 32
        # permission['FromPort'] != permission['ToPort'] || subnet_mask < 24
        permission['FromPort'] != permission['ToPort']
      end

      !violating_permissions.empty?
    end

    violating_gamelift_fleets.map(&:logical_resource_id)
  end
end
