require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/resource_base_rule'

describe ResourceBaseRule do
  describe '#audit' do
    it 'raises an error when properties are not set' do
      expect do
        ResourceBaseRule.new.audit_impl nil
      end.to raise_error 'must implement in subclass'
    end

    it 'returns a violation when the resource is found' do
      base_rule = ResourceBaseRule.new
      base_rule.instance_eval do
        def rule_id
          'F3333'
        end

        def rule_type
          Violation::FAILING_VIOLATION
        end

        def rule_text
          'This is an epic fail!'
        end

        def resource_type
          'AWS::SDB::Domain'
        end
      end

      # expect(base_rule).to receive(:resource_type).and_return('AWS::SDB::Domain')

      cfn_model = CfnParser.new.parse read_test_template 'yaml/amazon_simpledb/simpledb_domain_resource.yml'

      expected_violation = Violation.new(id: 'F3333',
                                         type: Violation::FAILING_VIOLATION,
                                         message: 'This is an epic fail!',
                                         logical_resource_ids: %w[NewSimpleDB])

      expect(base_rule.audit(cfn_model)).to eq expected_violation
    end

    it 'returns no violation when the resource is not found' do
      base_rule = ResourceBaseRule.new
      base_rule.instance_eval do
        def rule_id
          'F3333'
        end

        def rule_type
          Violation::FAILING_VIOLATION
        end

        def rule_text
          'This is an epic fail!'
        end

        def resource_type
          'AWS::SDB::Domain'
        end
      end

      # expect(base_rule).to receive(:resource_type).and_return('AWS::ElasticLoadBalancingV2::Listener')

      cfn_model = CfnParser.new.parse read_test_template 'yaml/amazon_simpledb/no_simpledb_domain_resource.yml'

      expect(base_rule.audit(cfn_model)).to be nil
    end
  end
end
