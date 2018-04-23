require 'spec_helper'
require 'cfn-model'
require 'cfn-nag/custom_rules/base'

describe BaseRule do
  describe '#audit_impl' do
    it 'raises an error' do
      expect do
        BaseRule.new.audit_impl nil
      end.to raise_error 'must implement in subclass'
    end
  end

  describe '#audit' do
    context 'audit_impl returns empty array' do
      it 'returns nil' do
        base_rule = BaseRule.new
        expect(base_rule).to receive(:audit_impl)
          .and_return([])

        dontcare = double('cfn_model')

        expect(base_rule.audit(dontcare)).to eq nil
      end
    end

    context 'audit_impl returns non-empty array' do
      it 'returns Violation based on the rule definition + the logical resource ids' do
        base_rule = BaseRule.new
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
        end

        expect(base_rule).to receive(:audit_impl)
          .and_return(%w[r1 r2 r3])

        dontcare = double('cfn_model')

        expected_violation = Violation.new(id: 'F3333',
                                           type: Violation::FAILING_VIOLATION,
                                           message: 'This is an epic fail!',
                                           logical_resource_ids: %w[r1 r2 r3])

        expect(base_rule.audit(dontcare)).to eq expected_violation
      end
    end
  end
end
