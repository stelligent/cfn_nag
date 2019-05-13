# frozen_string_literal: true
require 'spec_helper'
require 'cfn-nag/cfn_nag_logging'
require 'cfn-nag/cfn_nag_executor'

def cli_option_mock(input_path: nil,
                    fail_on_warnings: false,
                    blacklist_definition: nil,
                    parameter_values_path: nil,
                    profile_path: nil,
                    output_format: 'txt')
  {
    input_path: input_path,
    fail_on_warnings: fail_on_warnings,
    allow_suppression: true,
    blacklist_path: blacklist_definition,
    debug: false,
    isolate_custom_rule_exceptions: false,
    output_format: output_format,
    parameter_values_path: parameter_values_path,
    print_suppression: false,
    profile_path: profile_path,
    rule_directory: nil,
    template_pattern: '..*\.json|..*\.yaml|..*\.yml|..*\.template'
  }
end

describe CfnNagExecutor do
  before(:all) do
    CfnNagLogging.configure_logging(debug: false)
    @cfn_nag_executor = CfnNagExecutor.new
    @cfn_nag_scan_executor = CfnNagExecutor.new(require_input_path: true)
  end

  context 'single file cfn_nag with fail on warnings' do
    it 'returns a nonzero exit code' do
      test_file = File.new('spec/test_templates/yaml/ec2_subnet/ec2_subnet_map_public_ip_on_launch_true_boolean.yml', 'r')
      argf_mock = double('argf')
      allow(argf_mock).to receive(:eof?).and_return(false, true)
      allow(argf_mock).to receive(:closed?).and_return(false, true)
      allow(argf_mock).to receive(:file).and_return(test_file)
      allow(argf_mock).to receive(:close)
      result = @cfn_nag_executor.scan(aggregate_output: false,
                                      argf_supplier: argf_mock,
                                      cli_supplier: cli_option_mock(fail_on_warnings: true))
      test_file.close
      expect(result).to eq 1
    end
  end

  context 'single file cfn_nag' do
    it 'returns a successful zero exit code' do
      test_file = File.new('spec/test_templates/yaml/ec2_subnet/ec2_subnet_map_public_ip_on_launch_true_boolean.yml', 'r')
      argf_mock = double('argf')
      allow(argf_mock).to receive(:eof?).and_return(false, true)
      allow(argf_mock).to receive(:closed?).and_return(false, true)
      allow(argf_mock).to receive(:file).and_return(test_file)
      allow(argf_mock).to receive(:close)
      result = @cfn_nag_executor.scan(aggregate_output: false,
                                      argf_supplier: argf_mock,
                                      cli_supplier: cli_option_mock)
      test_file.close
      expect(result).to eq 0
    end
  end


  # this one triggers a trollop 'system exit' mid-flow :(
  context 'no input path specified' do
    it 'throws error on nil input_path' do
      expect { @cfn_nag_scan_executor.scan }.to raise_error(SystemExit)
    end
  end

  context 'input path specified with neptune directory' do
    it 'records three failures' do
      result = @cfn_nag_executor.scan(
        cli_supplier: cli_option_mock(input_path: 'spec/test_templates/json/neptune'))

      expect(result).to eq 3
    end
  end

  context 'input path specified with fail on warnings' do
    it 'records four failures' do
      result = @cfn_nag_executor.scan(
        cli_supplier: cli_option_mock(input_path: 'spec/test_templates/yaml/ec2_subnet',
                                      fail_on_warnings: true))

      expect(result).to eq 4
    end
  end

  context 'invalid value provided for output type' do
    it 'dies at validate_opts' do
      expect {
        @cfn_nag_executor.scan(cli_supplier: cli_option_mock(output_format: 'invalid'))
      }.to raise_error(SystemExit)
    end
  end

  context 'use profile, blacklist, and parameter path options' do
    it 'raises a TypeError once it tries to read the invalid files' do
      expect {
        @cfn_nag_executor.scan(cli_supplier: cli_option_mock(blacklist_definition: 'spec/cfn_nag_integration/test_path.txt',
                                                         parameter_values_path: 'spec/cfn_nag_integration/test_path.txt',
                                                         profile_path: 'spec/cfn_nag_integration/test_path.txt'))
      }.to raise_error(TypeError)
    end
  end
end
