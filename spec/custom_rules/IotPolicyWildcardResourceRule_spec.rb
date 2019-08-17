require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/IotPolicyWildcardResourceRule'

describe IotPolicyWildcardResourceRule do
  context 'policy with a wildcard Action' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse read_test_template('json/iot_policy/iot_policy_with_wildcard_resource.json') 
      actual_logical_resource_ids = IotPolicyWildcardResourceRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[IOT_Wildcard_Resource]
      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
