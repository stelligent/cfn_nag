require 'cfn-nag/rule_registry'
require 'cfn-nag/rule_definition'

describe RuleRegistry do
  describe '#definition' do
    context 'empty registry' do
      it 'adds a definition' do
        rule_registry = RuleRegistry.new
        rule_registry.definition(id: 'F444',
                                 type: RuleDefinition::WARNING,
                                 message: 'you have been warned!!')

        expected_rules = [
          RuleDefinition.new(id: 'F444',
                             type: RuleDefinition::WARNING,
                             message: 'you have been warned!!')
        ]

        expect(rule_registry.rules).to eq expected_rules

        # add a dupe
        rule_registry.definition(id: 'F444',
                                 type: RuleDefinition::WARNING,
                                 message: 'you have been warned!!')

        expect(rule_registry.rules).to eq expected_rules
      end
    end
  end

  context 'registry with definitions' do
    before(:each) do
      @rule_registry = RuleRegistry.new
      @rule_registry.definition(id: 'W444',
                                type: RuleDefinition::WARNING,
                                message: 'you have been warned!!')
      @rule_registry.definition(id: 'F999',
                                type: RuleDefinition::FAILING_VIOLATION,
                                message: 'you have failed!!')
    end

    describe '#by_id' do
      context 'bad id' do
        it 'returns nil' do
          expect(@rule_registry.by_id('MISSING')).to eq nil
        end
      end

      context 'good id' do
        it 'returns the rule def' do
          expected_rule = RuleDefinition.new(id: 'W444',
                                             type: RuleDefinition::WARNING,
                                             message: 'you have been warned!!')

          expect(@rule_registry.by_id('W444')).to eq expected_rule
        end
      end
    end

    describe '#warnings' do
      it 'returns all/only warnings' do
        expected_rules = [
          RuleDefinition.new(id: 'W444',
                             type: RuleDefinition::WARNING,
                             message: 'you have been warned!!')
        ]
        expect(@rule_registry.warnings).to eq expected_rules
      end
    end

    describe '#failures' do
      it 'returns all/only failures' do
        expected_rules = [
          RuleDefinition.new(id: 'F999',
                             type: RuleDefinition::FAILING_VIOLATION,
                             message: 'you have failed!!')
        ]
        expect(@rule_registry.failings).to eq expected_rules
      end
    end
  end
end
