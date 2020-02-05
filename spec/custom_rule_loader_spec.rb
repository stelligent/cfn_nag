require 'cfn-nag/custom_rule_loader'
require 'cfn-nag/rule_definition'
require 'cfn-nag/rule_registry'
require 'fileutils'

describe CustomRuleLoader do
  describe '#rule_definitions' do
    context 'no external rule directory' do
      it 'returns RuleRegistry with internal definitions' do
        actual_rule_registry = CustomRuleLoader.new.rule_definitions

        non_rules = actual_rule_registry.rules.select do |rule_definition|
          !rule_definition.is_a? RuleDefinition
        end
        expect(non_rules).to eq []
        expect(actual_rule_registry.rules.size).to be > 10
      end
    end

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
        @file_base_rule_repo = CustomRuleLoader.new(rule_directory: @custom_rule_directory)
      end

      after(:each) do
        FileUtils.rm_rf @custom_rule_directory
      end

      it 'does its thing' do
        cfn_model = CfnModel.new
        # for rules that mess with direct model
        cfn_model.raw_model = { 'Resources' => {} }

        actual_violations = @file_base_rule_repo.execute_custom_rules cfn_model, @file_base_rule_repo.rule_definitions
        expected_violations = [
          Violation.new(id: 'W9933',
                        type: Violation::WARNING,
                        message: 'this is fake rule text',
                        logical_resource_ids: %w[hardwired1 hardwired2])
        ]

        expect(actual_violations).to eq expected_violations
      end
    end
  end
end
