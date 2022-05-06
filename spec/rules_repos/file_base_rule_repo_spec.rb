require 'cfn-nag/rule_repos/file_based_rule_repo'
require 'cfn-nag/rule_definition'
require 'cfn-nag/rule_registry'
require 'fileutils'

describe FileBasedRuleRepo do
  describe '#discover_rules' do
    context 'external rule directory' do

      let(:valid_rule_text) do
        <<~RULE
          require 'cfn-nag/custom_rules/base'
          require 'cfn-nag/violation'
          class ValidCustomRule < BaseRule
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
      end

      let(:valid_rule_text2) do
        <<~RULE
          require 'cfn-nag/custom_rules/base'
          require 'cfn-nag/violation'
          class ValidCustom2Rule < BaseRule
            def rule_text
              'this is fake rule text 2'
            end

            def rule_type
              Violation::WARNING
            end

            def rule_id
              'W9934'
            end

            def audit_impl(cfn_model)
              %w(hardwired1 hardwired2)
            end
          end
        RULE
      end

      it 'includes external rule definition from absolute directories' do
        Dir.mktmpdir(%w[custom_rule loader]) do |custom_rule_directory|
          # Write out a valid rule
          File.write(File.join(custom_rule_directory, 'ValidCustomRule.rb'), valid_rule_text)
          # Write out a invalid rule
          File.write(File.join(custom_rule_directory, 'InvalidRuleNotMatching.rb'), 'fake_rule')

          core_rules_registry = FileBasedRuleRepo.new(nil).discover_rules
          actual_rule_registry = FileBasedRuleRepo.new(custom_rule_directory).discover_rules

          # Expect one additional rule loaded
          expect(actual_rule_registry.rules.size).to eq(core_rules_registry.rules.size+1)

          # Validate that the rule was loaded by id
          expected_rule_definition = RuleDefinition.new id: 'W9933',
                                                        name: 'ValidCustomRule',
                                                        message: 'this is fake rule text',
                                                        type: RuleDefinition::WARNING

          actual_rule_definition = actual_rule_registry.by_id 'W9933'
          expect(actual_rule_definition).to eq expected_rule_definition

          # Validate that the rule class was mapped correctly
          expected_rule_classes = 'ValidCustomRule'
          actual_rule_classes = actual_rule_registry.rule_classes.map { |rule_class| rule_class.name }
          expect(actual_rule_classes.include?(expected_rule_classes)).to be true
        end
      end

      it 'includes external rule definition from relative' do
        Dir.mktmpdir(%w[custom_rule loader], Dir.getwd) do |custom_rule_directory|
          # Write out a valid rule
          File.write(File.join(custom_rule_directory, 'ValidCustomRule.rb'), valid_rule_text)
          # Write out a invalid rule
          File.write(File.join(custom_rule_directory, 'InvalidRuleNotMatching.rb'), 'fake_rule')

          core_rules_registry = FileBasedRuleRepo.new(nil).discover_rules
          actual_rule_registry = FileBasedRuleRepo.new(File.basename(custom_rule_directory)).discover_rules

          # Expect one additional rule loaded
          expect(actual_rule_registry.rules.size).to eq(core_rules_registry.rules.size+1)

          # Validate that the rule was loaded by id
          expected_rule_definition = RuleDefinition.new id: 'W9933',
                                                        name: 'ValidCustomRule',
                                                        message: 'this is fake rule text',
                                                        type: RuleDefinition::WARNING

          actual_rule_definition = actual_rule_registry.by_id 'W9933'
          expect(actual_rule_definition).to eq expected_rule_definition

          # Validate that the rule class was mapped correctly
          expected_rule_classes = 'ValidCustomRule'
          actual_rule_classes = actual_rule_registry.rule_classes.map { |rule_class| rule_class.name }
          expect(actual_rule_classes.include?(expected_rule_classes)).to be true
        end
      end

      it 'includes external rule definitions from subdirectories' do
        Dir.mktmpdir(%w[custom_rule loader], Dir.getwd) do |custom_rule_directory|
          # Write out a valid rule
          File.write(File.join(custom_rule_directory, 'ValidCustomRule.rb'), valid_rule_text)
          # Create a subdirectory for rules
          rule_subdir = File.join(custom_rule_directory, 'subdir')
          Dir.mkdir(rule_subdir)
          # Write a rule in a subdirectory
          File.write(File.join(rule_subdir, 'ValidCustom2Rule.rb'), valid_rule_text2)
          # Write out a invalid rule
          File.write(File.join(custom_rule_directory, 'InvalidRuleNotMatching.rb'), 'fake_rule')

          core_rules_registry = FileBasedRuleRepo.new(nil).discover_rules
          actual_rule_registry = FileBasedRuleRepo.new(File.basename(custom_rule_directory),
                                                       rule_directory_recursive: true).discover_rules

          # Expect one additional rule loaded
          expect(actual_rule_registry.rules.size).to eq(core_rules_registry.rules.size+2)

          # Validate that the rule was loaded by id
          expected_rule_definition = RuleDefinition.new id: 'W9933',
                                                        name: 'ValidCustomRule',
                                                        message: 'this is fake rule text',
                                                        type: RuleDefinition::WARNING

          actual_rule_definition = actual_rule_registry.by_id 'W9933'
          expect(actual_rule_definition).to eq expected_rule_definition

          # Validate that the rule was loaded by id
          expected_rule_definition = RuleDefinition.new id: 'W9934',
                                                        name: 'ValidCustom2Rule',
                                                        message: 'this is fake rule text 2',
                                                        type: RuleDefinition::WARNING

          actual_rule_definition = actual_rule_registry.by_id 'W9934'
          expect(actual_rule_definition).to eq expected_rule_definition

          # Validate that the rule class was mapped correctly
          actual_rule_classes = actual_rule_registry.rule_classes.map { |rule_class| rule_class.name }
          expect(actual_rule_classes.include?('ValidCustomRule')).to be true
          expect(actual_rule_classes.include?('ValidCustom2Rule')).to be true
        end
      end
    end
  end
end
