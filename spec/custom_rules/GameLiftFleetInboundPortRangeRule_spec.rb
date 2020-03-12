# frozen_string_literal: true

require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/GameLiftFleetInboundPortRangeRule'

describe GameLiftFleetInboundPortRangeRule do
  context 'GameLift fleet with IpPermissions open to port range' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/gamelift/fleet_open_to_port_range.json')

      actual_logical_resource_ids = GameLiftFleetInboundPortRangeRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[InsecureGameLiftFleet]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'GameLift fleet open to only individual ports' do
    it 'does not return logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/gamelift/fleet_open_to_individual_ports.json')

      actual_logical_resource_ids = GameLiftFleetInboundPortRangeRule.new.audit_impl cfn_model

      expect(actual_logical_resource_ids).to eq []
    end
  end
end
