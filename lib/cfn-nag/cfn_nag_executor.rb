# frozen_string_literal: true

require 'trollop'
require 'cfn-nag/cli_options'
require 'cfn-nag/cfn_nag_config'

class CfnNagExecutor
  def initialize(require_input_path: false)
    @require_input_path = require_input_path
    @profile_definition = nil
    @blacklist_definition = nil
    @parameter_values_string = nil
  end

  def scan(aggregate_output: true,
           cli_supplier: cli_options(require_input_path: @require_input_path),
           argf_supplier: ARGF)
    opts = cli_supplier
    validate_options(opts)
    execute_io_options(opts)

    CfnNagLogging.configure_logging(opts)

    cfn_nag = CfnNag.new(
      config: cfn_nag_config(opts)
    )

    aggregate_output ? execute_aggregate_scan(cfn_nag, opts) : execute_single_scan(cfn_nag, opts, argf_supplier)
  end

  private

  def execute_single_scan(cfn_nag, opts, argf)
    total_failure_count = 0
    until argf.closed? || argf.eof?
      results = cfn_nag.audit(cloudformation_string: argf.file.read,
                              parameter_values_string: @parameter_values_string)
      argf.close

      total_failure_count += if opts[:fail_on_warnings]
                               results[:violations].length
                             else
                               results[:failure_count]
                             end

      results[:violations] = results[:violations].map(&:to_h)
      puts JSON.pretty_generate(results)
    end
    total_failure_count
  end

  def execute_aggregate_scan(cfn_nag, opts)
    cfn_nag.audit_aggregate_across_files_and_render_results(
      input_path: opts[:input_path],
      output_format: opts[:output_format],
      parameter_values_path: opts[:parameter_values_path],
      template_pattern: opts[:template_pattern]
    )
  end

  def validate_options(opts)
    unless %w[txt json].include?(opts[:output_format])
      Trollop.die(:output_format,
                  'Must be txt or json')
    end
  end

  def execute_io_options(opts)
    unless opts[:profile_path].nil?
      @profile_definition = IO.read(opts[:profile_path])
    end

    unless opts[:blacklist_path].nil?
      @blacklist_definition = IO.read(opts[:blacklist_path])
    end

    unless opts[:parameter_values_path].nil?
      @parameter_values_string = IO.read(opts[:parameter_values_path])
    end
  end

  def cfn_nag_config(opts)
    CfnNagConfig.new(
      profile_definition: @profile_definition,
      blacklist_definition: @blacklist_definition,
      rule_directory: opts[:rule_directory],
      allow_suppression: opts[:allow_suppression],
      print_suppression: opts[:print_suppression],
      isolate_custom_rule_exceptions: opts[:isolate_custom_rule_exceptions],
      fail_on_warnings: opts[:fail_on_warnings]
    )
  end
end
