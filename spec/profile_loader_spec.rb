require 'spec_helper'
require 'profile_loader'
require 'rule_registry'
require 'set'

describe ProfileLoader, :profile do

  describe '#load' do
    context 'empty profile' do

      it 'should raise an error' do

        expect {
          ProfileLoader.new(nil).load profile_definition: ''
        }.to raise_error 'Empty profile'
      end
    end

    context 'non-existent rule number' do
      before(:all) do
        @rule_registry = RuleRegistry.new

        @rule_registry.definition(id: 'id1',
                                  type: Violation::WARNING,
                                  message: 'fakeo')
        @rule_registry.definition(id: 'id2',
                                  type: Violation::WARNING,
                                  message: 'fakeo2')
      end

      it 'should raise an error' do

        expect {
          ProfileLoader.new(@rule_registry).load profile_definition: 'FAKEID'
        }.to raise_error 'FAKEID is not a legal rule identifier'
      end

      it 'should return a profile object' do

        new_profile = ProfileLoader.new(@rule_registry).load profile_definition: "id1\nid2"
        expect(new_profile.rule_ids).to eq Set.new %w(id1 id2)
      end
    end
  end
end