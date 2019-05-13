# frozen_string_literal: true
require 'spec_helper'
require 'cfn-nag/cfn_nag_logging'
require 'cfn-nag/cfn_nag_executor'

def cli_option_mock(input_path: nil, fail_on_warnings: false)
  {
    input_path: input_path,
    fail_on_warnings: fail_on_warnings,
    allow_suppression: true,
    blacklist_path: nil,
    debug: false,
    isolate_custom_rule_exceptions: false,
    output_format: 'txt',
    parameter_values_path: nil,
    print_suppression: false,
    profile_path: nil,
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
end
