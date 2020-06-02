# frozen_string_literal: true

require 'optimist'

# rubocop:disable Metrics/ClassLength
class Options
  @custom_rule_exceptions_message = 'Isolate custom rule exceptions - just ' \
                                   'emit the exception without stack trace ' \
                                   'and keep chugging'

  @version = Gem::Specification.find_by_name('cfn-nag').version

  def self.for(type)
    case type
    when 'file'
      file_options
    when 'scan'
      scan_options
    else
      raise "Unsupported Options type #{type}; use 'file' or 'scan'"
    end
  end

  # rubocop:disable Metrics/BlockLength
  # rubocop:disable Metrics/MethodLength
  def self.file_options
    options_message = '[options] <cloudformation template path ...>|' \
                        '<cloudformation template in STDIN>'
    custom_rule_exceptions_message = @custom_rule_exceptions_message
    version = @version

    Optimist.options do
      usage options_message
      version version

      opt :debug,
          'Enable debug output',
          type: :boolean,
          required: false,
          default: false
      opt :allow_suppression,
          'Allow using Metadata to suppress violations',
          type: :boolean,
          required: false,
          default: true
      opt :print_suppression,
          'Emit suppressions to stderr',
          type: :boolean,
          required: false,
          default: false
      opt :rule_directory,
          'Extra rule directory',
          type: :string,
          required: false,
          default: nil
      opt :profile_path,
          'Path to a profile file',
          type: :string,
          required: false,
          default: nil
      opt :blacklist_path,
          'Path to a blacklist file',
          type: :string,
          required: false,
          default: nil
      opt :parameter_values_path,
          'Path to a JSON file to pull Parameter values from',
          type: :string,
          required: false,
          default: nil
      opt :condition_values_path,
          'Path to a JSON file to pull Condition values from',
          type: :string,
          required: false,
          default: nil
      opt :isolate_custom_rule_exceptions,
          custom_rule_exceptions_message,
          type: :boolean,
          required: false,
          default: false
      opt :fail_on_warnings,
          'Treat warnings as failing violations',
          type: :boolean,
          required: false,
          default: false
      opt :output_format,
          'Format of results: [txt, json, colortxt]',
          type: :string,
          default: 'colortxt'
      opt :rule_repository,
          'Path(s) to a rule repository to include in rule discovery',
          type: :strings,
          required: false
      opt :rule_arguments,
          'Rule arguments to inject into interested rules',
          type: :strings,
          required: false
      opt :rule_arguments_path,
          'Path to a rule arguments to inject into interested rules',
          type: :string,
          required: false,
          default: nil
      opt :ignore_fatal,
          'Ignore files with fatal violations.  Useful for ignoring non-Cloudformation yaml/yml/json in a path',
          type: :boolean,
          required: false,
          default: false
    end
  end

  def self.scan_options
    input_path_message = 'CloudFormation template to nag on or directory of ' \
                         'templates.  Default is all *.json, *.yaml, *.yml ' \
                         'and *.template recursively, but can be constrained ' \
                         'by --template-pattern'

    template_pattern_message = 'Within the --input-path, match files to scan ' \
                               'against this regular expression'

    custom_rule_exceptions_message = @custom_rule_exceptions_message
    version = @version

    Optimist.options do
      version version
      opt :input_path,
          input_path_message,
          type: :string,
          required: true
      opt :output_format,
          'Format of results: [txt, json, colortxt]',
          type: :string,
          default: 'colortxt'
      opt :debug,
          'Enable debug output',
          type: :boolean,
          required: false,
          default: false
      opt :rule_directory,
          'Extra rule directory',
          type: :string,
          required: false,
          default: nil
      opt :profile_path,
          'Path to a profile file',
          type: :string,
          required: false,
          default: nil
      opt :blacklist_path,
          'Path to a blacklist file',
          type: :string,
          required: false,
          default: nil
      opt :parameter_values_path,
          'Path to a JSON file to pull Parameter values from',
          type: :string,
          required: false,
          default: nil
      opt :condition_values_path,
          'Path to a JSON file to pull Condition values from',
          type: :string,
          required: false,
          default: nil
      opt :allow_suppression,
          'Allow using Metadata to suppress violations',
          type: :boolean,
          required: false,
          default: true
      opt :print_suppression,
          'Emit suppressions to stderr',
          type: :boolean,
          required: false,
          default: false
      opt :isolate_custom_rule_exceptions,
          custom_rule_exceptions_message,
          type: :boolean,
          required: false,
          default: false
      opt :template_pattern,
          template_pattern_message,
          type: :string,
          required: false,
          default: '..*\.json|..*\.yaml|..*\.yml|..*\.template'
      opt :fail_on_warnings,
          'Treat warnings as failing violations',
          type: :boolean,
          required: false,
          default: false
      opt :rule_repository,
          'Path(s)s to rule repository to include in rule discovery',
          type: :strings,
          required: false
      opt :rule_arguments,
          'Rule arguments to inject into interested rules',
          type: :strings,
          required: false
      opt :rule_arguments_path,
          'Path to a rule arguments to inject into interested rules',
          type: :string,
          required: false,
          default: nil
      opt :ignore_fatal,
          'Ignore files with fatal violations.  Useful for ignoring non-Cloudformation yaml/yml/json in a path',
          short: 'g',
          type: :boolean,
          required: false,
          default: false
    end
  end
  # rubocop:enable Metrics/BlockLength
  # rubocop:enable Metrics/MethodLength
end
# rubocop:enable Metrics/ClassLength
