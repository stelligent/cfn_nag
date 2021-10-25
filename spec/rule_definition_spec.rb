require 'cfn-nag/rule_definition'

describe RuleDefinition do
  context 'missing constructor attribute' do
    it 'raises an error' do
      expect do
        RuleDefinition.new(id: nil,
                           name: 'BadRule',
                           type: RuleDefinition::FAILING_VIOLATION,
                           message: 'EBS volume should have server-side encryption enabled')
      end.to raise_error 'No parameters to Violation constructor can be nil'
    end
  end

  describe '#to_s' do
    it 'emits attributes' do
      violation = RuleDefinition.new(id: 'F99',
                                     name: 'F9Rule',
                                     type: RuleDefinition::FAILING_VIOLATION,
                                     message: 'EBS volume should have server-side encryption enabled')
      expect(violation.to_s).to eq 'F99 F9Rule FAIL EBS volume should have server-side encryption enabled'
    end
  end

  describe '#==' do
    context 'unequal' do
      it 'return false' do
        v1 = RuleDefinition.new(id: 'F1',
                                name: 'F1Rule',
                                type: RuleDefinition::FAILING_VIOLATION,
                                message: 'EBS volume should have server-side encryption enabled')

        v2 = RuleDefinition.new(id: 'F2',
                                name: 'F2Rule',
                                type: RuleDefinition::FAILING_VIOLATION,
                                message: 'EBS volume should have server-side encryption enabled')

        expect(v1).to_not eq v2
      end
    end

    context 'equal' do
      it 'return true' do
        v1 = RuleDefinition.new(id: 'F1',
                                name: 'F1Rule',
                                type: RuleDefinition::FAILING_VIOLATION,
                                message: 'EBS volume should have server-side encryption enabled')

        v2 = RuleDefinition.new(id: 'F1',
                                name: 'F1Rule',
                                type: RuleDefinition::FAILING_VIOLATION,
                                message: 'EBS volume should have server-side encryption enabled')

        expect(v1).to eq v2
      end
    end
  end
end
