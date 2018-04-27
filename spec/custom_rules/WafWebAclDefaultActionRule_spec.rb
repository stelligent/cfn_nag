require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/WafWebAclDefaultActionRule'

describe WafWebAclDefaultActionRule do
  context 'WebAcl with DefaultAction of ALLOW' do
    it 'returns offending logical resource id' do
      cfn_model = CfnParser.new.parse(
        read_test_template('json/waf_webacl/waf_webacl_with_default_allow.json')
      )

      actual_logical_resource_ids = WafWebAclDefaultActionRule.new.audit_impl cfn_model
      expected_logical_resource_ids = %w[WAFWebACL]

      expect(actual_logical_resource_ids).to eq expected_logical_resource_ids
    end
  end
end
