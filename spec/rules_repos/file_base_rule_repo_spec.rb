require 'cfn-nag/rule_repos/file_based_rule_repo'
require 'cfn-nag/rule_definition'
require 'cfn-nag/rule_registry'
require 'fileutils'

describe FileBasedRuleRepo do
  describe '#discover_rules' do
    context 'external rule directory' do
      before(:each) do
        fake_rule = <<RULE
require 'cfn-nag/custom_rules/base'
require 'cfn-nag/violation'

class FakeRule < BaseRule
  def rule_text
    'this is fake rule text'
  end

  def rule_type
    Violation::WARNING
  end

  def rule_id
    'W9933'
  end

  def audit_impl(cfn_model)
    %w(hardwired1 hardwired2)
  end
end
RULE
        @custom_rule_directory = Dir.mktmpdir(%w[custom_rule loader])
        File.open(File.join(@custom_rule_directory,
                            'FakeRule.rb'),
                  'w+') { |file| file.write fake_rule }
        @file_base_rule_repo = FileBasedRuleRepo.new(@custom_rule_directory)
      end

      after(:each) do
        FileUtils.rm_rf @custom_rule_directory
      end

      it 'includes external rule definition' do
        actual_rule_registry = @file_base_rule_repo.discover_rules
        expected_rule_definition = RuleDefinition.new id: 'W9933',
                                                      message: 'this is fake rule text',
                                                      type: RuleDefinition::WARNING

        actual_rule_definition = actual_rule_registry.by_id 'W9933'
        expect(actual_rule_definition).to eq expected_rule_definition

        expected_rule_classes = 'FakeRule'
        actual_rule_classes = actual_rule_registry.rule_classes.map { |rule_class| rule_class.name }
        expect(actual_rule_classes.include?(expected_rule_classes)).to be true
      end
    end
  end
end
