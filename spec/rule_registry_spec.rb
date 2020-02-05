require 'cfn-nag/rule_registry'
require 'cfn-nag/rule_definition'

class F444Rule
  def rule_text
    'you have been warned!!'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'F444'
  end
end

class F444DupeRule
  def rule_text
    'you have been warned!! dupe'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'F444'
  end
end

class W444Rule
  def rule_text
    'you have been warned!!'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W444'
  end
end

class F999Rule
  def rule_text
    'you have failed!!'
  end

  def rule_type
    Violation::FAILING_VIOLATION
  end

  def rule_id
    'F999'
  end
end


describe RuleRegistry do
  describe '#definition' do
    context 'empty registry' do
      it 'adds a definition' do
        rule_registry = RuleRegistry.new

        rule_registry.definition(F444Rule)

        expected_rules = [
          RuleDefinition.new(id: 'F444',
                             type: RuleDefinition::WARNING,
                             message: 'you have been warned!!')
        ]

        expect(rule_registry.rules).to eq expected_rules
        expect(rule_registry.duplicate_ids?).to be false

        # add a dupe
        rule_registry.definition(F444DupeRule)

        expected_duplicate = {
          id: 'F444',
          new_message: 'you have been warned!! dupe',
          registered_message: 'you have been warned!!'
        }

        expect(rule_registry.rules).to eq expected_rules
        expect(rule_registry.duplicate_ids?).to be true
        expect(rule_registry.duplicate_ids.first).to eq expected_duplicate
      end
    end
  end

  context 'registry with definitions' do
    before(:each) do
      @rule_registry = RuleRegistry.new
      @rule_registry.definition(W444Rule)
      @rule_registry.definition(F999Rule)
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
