require 'cfn-nag/rule_repos/gem_based_rule_repo'
require 'cfn-nag/rule_registry'
require 'set'

describe GemBasedRuleRepo do
  ## this test just makes sure the code doesnt blow in an obvious way
  # not going to spend the time here to fake out the gem api... will get this on an e2e test
  context 'dunno' do
    it 'does not blow' do
      rule_registry = GemBasedRuleRepo.new.discover_rules
      expect(rule_registry.rule_classes).to eq(Set.new([]))
    end
  end
end
