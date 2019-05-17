# frozen_string_literal: true
require 'spec_helper'
require 'cfn-nag/cfn_nag_logging'
require 'cfn-nag/cfn_nag_executor'

describe CfnNagExecutor do
  before(:all) do
    CfnNagLogging.configure_logging(debug: false)
    @cfn_nag_executor = CfnNagExecutor.new
  end

  context 'single file cfn_nag with fail on warnings' do
    it 'returns a nonzero exit code' do
      test_file = 'spec/test_templates/yaml/ec2_subnet/ec2_subnet_map_public_ip_on_launch_true_boolean.yml'
      argf = Argf.for('force')
      argf.use_file(test_file: test_file)
      options = Options.for('force')
      options.set(fail_on_warnings: true)
      result = @cfn_nag_executor.scan(argf: argf,
                                      options: options)
      expect(result).to eq 1
    end
  end

  context 'single file cfn_nag' do
    it 'returns a successful zero exit code' do
      test_file = 'spec/test_templates/yaml/ec2_subnet/ec2_subnet_map_public_ip_on_launch_true_boolean.yml'
      argf = Argf.for('force')
      argf.use_file(test_file: test_file)
      options = Options.for('force')
      options.set
      result = @cfn_nag_executor.scan(argf: argf,
                                      options: options)
      expect(result).to eq 0
    end
  end

  # this one triggers a trollop 'system exit' mid-flow :(
  context 'no input path specified' do
    it 'throws error on nil input_path' do
      expect {
        @cfn_nag_executor.scan(cfn_nag_scan: true,
                               options: Options.for('cli'),
                               argf: Argf.for('argf'))
      }.to raise_error(SystemExit)
    end
  end

  context 'input path specified with neptune directory' do
    it 'records three failures' do
      options = Options.for('force')
      options.set(input_path: 'spec/test_templates/json/neptune')
      result = @cfn_nag_executor.scan(cfn_nag_scan: true,
                                      options: options,
                                      argf: Argf.for('argf'))

      expect(result).to eq 3
    end
  end

  context 'input path specified with fail on warnings' do
    it 'records four failures' do
      options = Options.for('force')
      options.set(input_path: 'spec/test_templates/yaml/ec2_subnet',
                  fail_on_warnings: true)
      result = @cfn_nag_executor.scan(cfn_nag_scan: true,
                                      options: options,
                                      argf: Argf.for('argf'))

      expect(result).to eq 4
    end
  end

  context 'invalid value provided for output type' do
    it 'dies at validate_opts' do
      options = Options.for('force')
      options.set(output_format: 'invalid')
      expect {
        @cfn_nag_executor.scan(cfn_nag_scan: true,
                               options: options,
                               argf: Argf.for('argf'))
      }.to raise_error(SystemExit)
    end
  end

  context 'use profile, blacklist, and parameter path options' do
    it 'raises a TypeError once it tries to read the invalid files' do
      options = Options.for('force')
      options.set(blacklist_definition: 'spec/cfn_nag_integration/test_path.txt',
                  parameter_values_path: 'spec/cfn_nag_integration/test_path.txt',
                  profile_path: 'spec/cfn_nag_integration/test_path.txt')
      expect {
        @cfn_nag_executor.scan(cfn_nag_scan: true,
                               options: options,
                               argf: Argf.for('argf'))
      }.to raise_error(TypeError)
    end
  end

  context 'invalid Options and Argf types' do
    it 'raises errors' do
      expect {Options.for('invalid')}.to raise_error(RuntimeError)
      expect {Argf.for('invalid')}.to raise_error(RuntimeError)
    end
  end

  context 'no command line options specified' do
    it 'has no value for input_path' do
      options = Options.for('cli')
      expect(options.get[:input_path]).to eq nil
    end
  end
end
