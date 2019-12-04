# frozen_string_literal: true

require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/VpcHasFlowLogRule'

describe VpcHasFlowLogRule do
  context 'vpc without a flow log' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/vpc/vpc_missing_flowlog.yml')

      actual_logical_resource_ids = VpcHasFlowLogRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[Vpc]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end

  context 'vpc with a flow log' do
    it 'returns no logical resource ids' do
      cfn_model = CfnParser.new.parse read_test_template('yaml/vpc/vpc_has_flowlog.yml')

      expect(VpcHasFlowLogRule.new.audit(cfn_model)).to be nil
    end
  end
end
