require 'spec_helper'
require 'cfn-nag/profile_loader'
require 'cfn-nag/rule_registry'
require 'cfn-nag/result_view/rules_view'
require 'set'

describe ProfileLoader do
  describe '#load' do
    before(:all) do
      @rule_registry = RuleRegistry.new

      @rule_registry.definition(id: 'id1',
                                type: Violation::WARNING,
                                message: 'fakeo')
      @rule_registry.definition(id: 'id2',
                                type: Violation::WARNING,
                                message: 'fakeo2')
    end

    context 'empty profile' do
      it 'should raise an error' do
        expect do
          ProfileLoader.new(nil).load profile_definition: ''
        end.to raise_error 'Empty profile'
      end
    end

    context 'non-existent rule number' do
      it 'should raise an error' do
        expect do
          ProfileLoader.new(@rule_registry).load profile_definition: 'FAKEID1'
        end.to raise_error # 'FAKEID is not a legal rule identifier'
      end

      it 'should return a profile object' do
        new_profile = ProfileLoader.new(@rule_registry)
                                   .load profile_definition: "id1\nid2"
        expect(new_profile.rule_ids).to eq Set.new %w[id1 id2]
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
        new_profile = ProfileLoader.new(@rule_registry)
                                   .load profile_definition: @rule_view_output
        expect(new_profile.rule_ids).to eq Set.new %w[id1 id2]
      end
    end
  end
end
