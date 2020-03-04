require 'spec_helper'
require 'cfn-nag/profile_loader'
require 'cfn-nag/rule_registry'
require 'set'


class Rule1
  def rule_text
    'fakeo'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'id1'
  end
end

class Rule2
  def rule_text
    'fakeo2'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'id2'
  end
end

describe ProfileLoader do
  describe '#load' do
    before(:all) do
      @rule_registry = RuleRegistry.new

      @rule_registry.definition(Rule1)
      @rule_registry.definition(Rule2)
    end

    context 'empty profile' do
      it 'should raise an error' do
        expect do
          ProfileLoader.new(nil).load profile_definition: ''
        end.to raise_error 'Empty profile'
      end
    end

    context 'happy path' do
      it 'should return a profile object' do
        new_profile = ProfileLoader.new(@rule_registry).load profile_definition: "id1\nid2"
        expect(new_profile.rule_ids).to eq Set.new %w[id1 id2]
      end
    end

    context 'non-existent rule number' do
      it 'should raise an error' do
        expect do
          ProfileLoader.new(@rule_registry).load profile_definition: 'FAKEID1'
        end.to raise_error RuntimeError, /FAKEID1 is not a legal rule identifier/
      end
    end

    context 'load profile using rule dump format' do
      before(:all) do
        @rule_view_output = <<OUTPUT
WARNING VIOLATIONS:

FAILING VIOLATIONS:
id1 fakeo
id2 fakeo2
OUTPUT
      end

      it 'should parse the rule dump format' do
        new_profile = ProfileLoader.new(@rule_registry).load profile_definition: @rule_view_output
        expect(new_profile.rule_ids).to eq Set.new %w[id1 id2]
      end
    end
  end
end
