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
end
