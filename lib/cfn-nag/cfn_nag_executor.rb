# frozen_string_literal: true

require 'optimist'
require 'cfn-nag/cli_options'
require 'cfn-nag/cfn_nag_config'

class CfnNagExecutor
  def initialize
    @profile_definition = nil
    @blacklist_definition = nil
    @parameter_values_string = nil
    @condition_values_string = nil
    @rule_repository_definitions = []
  end

  def scan(options_type:)
    @total_failure_count = 0

    options = Options.for(options_type)
    validate_options(options)
    execute_io_options(options)

    CfnNagLogging.configure_logging(options)

    cfn_nag = CfnNag.new(
      config: cfn_nag_config(options)
    )

    options_type == 'scan' ? execute_aggregate_scan(cfn_nag, options) : execute_file_or_piped_scan(cfn_nag, options)
  end

  private

  def execute_file_or_piped_scan(cfn_nag, opts)
    aggregate_results = []

    until argf_finished?
      aggregate_results << scan_file(cfn_nag, opts[:fail_on_warnings])
      argf_close
    end

    cfn_nag.render_results(aggregate_results: aggregate_results,
                           output_format: opts[:output_format])

    @total_failure_count
  end

  def execute_aggregate_scan(cfn_nag, opts)
    cfn_nag.audit_aggregate_across_files_and_render_results(
      input_path: opts[:input_path],
      output_format: opts[:output_format],
      parameter_values_path: opts[:parameter_values_path],
      condition_values_path: opts[:condition_values_path],
      template_pattern: opts[:template_pattern]
    )
  end

  def scan_file(cfn_nag, fail_on_warnings)
    audit_result = cfn_nag.audit(cloudformation_string: argf_read,
                                 parameter_values_string: @parameter_values_string,
                                 condition_values_string: @condition_values_string)

    @total_failure_count += if fail_on_warnings
                              audit_result[:violations].length
                            else
                              audit_result[:failure_count]
                            end

    {
      filename: argf_filename,
      file_results: audit_result
    }
  end

  def validate_options(opts)
    unless opts[:output_format].nil? || %w[colortxt txt json].include?(opts[:output_format])
      Optimist.die(:output_format,
                   'Must be colortxt, txt, or json')
    end
  end

  def execute_io_options(opts)
    @profile_definition = read_conditionally(opts[:profile_path])

    @blacklist_definition = read_conditionally(opts[:blacklist_path])

    @parameter_values_string = read_conditionally(opts[:parameter_values_path])

    @condition_values_string = read_conditionally(opts[:condition_values_path])

    opts[:rule_repository]&.each do |rule_repository|
      @rule_repository_definitions << IO.read(rule_repository)
    end
  end

  def read_conditionally(path)
    unless path.nil?
      IO.read(path)
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
      fail_on_warnings: opts[:fail_on_warnings],
      rule_repository_definitions: @rule_repository_definitions
    )
  end

  def argf_finished?
    ARGF.closed? || ARGF.eof?
  end

  def argf_close
    ARGF.close
  end

  def argf_read
    ARGF.set_encoding(Encoding::UTF_8)
    ARGF.file.read
  end

  def argf_filename
    ARGF.filename
  end
end
