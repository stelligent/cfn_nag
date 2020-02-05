# frozen_string_literal: true

require 'cfn-nag/rule_dumper'

# Objectspace iterating and rspec-mocks double() don't mix

describe CfnNagRuleDumper do
  context 'no profile' do
    before(:each) do
      @rule_dumper = CfnNagRuleDumper.new
    end

    it 'emits list of rules' do
      @rule_dumper.dump_rules
    end
  end

  context 'simple profile and txt output format' do
    before(:each) do
      @rule_dumper = CfnNagRuleDumper.new profile_definition: "F1\nF9\n",
                                          rule_directory: nil,
                                          output_format: 'txt'
    end

    it 'emits list of rules in text' do
      expected_output = <<OUTPUTSTRING
WARNING VIOLATIONS:

FAILING VIOLATIONS:
F1 EBS volume should have server-side encryption enabled
F9 S3 Bucket policy should not allow Allow+NotPrincipal
OUTPUTSTRING

      expect do
        @rule_dumper.dump_rules
      end.to output(expected_output).to_stdout
    end
  end

  context 'simple profile and csv ouput format' do
    before(:each) do
      @rule_dumper = CfnNagRuleDumper.new profile_definition: "F1\nF9\n",
                                          rule_directory: nil,
                                          output_format: 'csv'
    end

    it 'emits list of rules in csv' do
      expected_output = <<OUTPUTSTRING
Type,ID,Message
FAIL,F1,"EBS volume should have server-side encryption enabled"
FAIL,F9,"S3 Bucket policy should not allow Allow+NotPrincipal"
OUTPUTSTRING

      expect do
        @rule_dumper.dump_rules
      end.to output(expected_output).to_stdout
    end
  end

  context 'simple profile amd json format' do
    before(:each) do
      @rule_dumper = CfnNagRuleDumper.new profile_definition: "F1\nF9\n",
                                          rule_directory: nil,
                                          output_format: 'json'
    end

    it 'emits list of rules in json' do
      expected_output = <<OUTPUTSTRING
[
  {
    "id": "F1",
    "type": "FAIL",
    "message": "EBS volume should have server-side encryption enabled"
  },
  {
    "id": "F9",
    "type": "FAIL",
    "message": "S3 Bucket policy should not allow Allow+NotPrincipal"
  }
]

OUTPUTSTRING

      expect do
        @rule_dumper.dump_rules
      end.to output(expected_output).to_stdout
    end
  end
end
