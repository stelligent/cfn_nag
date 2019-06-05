require 'spec_helper'

describe 'cfn_nag_rules', end_to_end: true do
  context 'listing default installed rules' do
    stdout,stderr,status = Open3.capture3("cfn_nag_rules")
    it 'prints out core rules for warning violations' do
      warning_rule_count = stdout.split("\n").select{|warning| warning.start_with?(/W\d/)}.count

      expect(warning_rule_count).not_to eq 0
    end

    it 'prints out core rules for failure violations' do
      failure_rule_count = stdout.split("\n").select{|warning| warning.start_with?(/F\d/)}.count

      expect(failure_rule_count).not_to eq 0
    end
  end

  context 'detecting a duplicate rule id' do
    before(:all) do
      @duplicate_rule = 'lib/cfn-nag/custom_rules/DuplicateRule.rb'
      duplicate_rule_content = <<-CONTENT
      require 'cfn-nag/violation'
      require_relative 'base'

      class DuplicateRule < BaseRule
        def rule_text
          'Example duplicate rule'
        end

        def rule_type
          Violation::FAILING_VIOLATION
        end

        def rule_id
          'F1'
        end

        def audit_impl(cfn_model); end
      end
CONTENT
      File.open(@duplicate_rule, 'w') {|f| f.write(duplicate_rule_content) }
      @stdout,@stderr,@status = Open3.capture3("bundle exec ./bin/cfn_nag_rules")
    end

    after(:all) do
      File.delete(@duplicate_rule)
    end

    it 'blah' do
      puts @status.exitstatus
      expect(@status.exitstatus).to eq 1
    end
  end
end
