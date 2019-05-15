# frozen_string_literal: true

require 'trollop'

# rubocop:disable Metrics/BlockLength
# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
def cli_options(cfn_nag_scan: false)
  options_message = '[options] <cloudformation template path ...>|' \
                    '<cloudformation template in STDIN>'

  input_path_message = 'CloudFormation template to nag on or directory of ' \
                       'templates.  Default is all *.json, *.yaml, *.yml ' \
                       'and *.template recursively, but can be constrained ' \
                       'by --template-pattern'

  custom_rule_exceptions_message = 'Isolate custom rule exceptions - just ' \
                                   'emit the exception without stack trace ' \
                                   'and keep chugging'

  template_pattern_message = 'Within the --input-path, match files to scan ' \
                             'against this regular expression'

  version = Gem::Specification.find_by_name('cfn-nag').version

  if cfn_nag_scan
    Trollop.options do
      version version
      opt :input_path,
          input_path_message,
          type: :io,
          required: true
      opt :output_format,
          'Format of results: [txt, json]',
          type: :string,
          default: 'txt'
      opt :debug,
          'Enable debug output',
          type: :boolean,
          required: false,
          default: false
      opt :rule_directory,
          'Extra rule directory',
          type: :io,
          required: false,
          default: nil
      opt :profile_path,
          'Path to a profile file',
          type: :io,
          required: false,
          default: nil
      opt :blacklist_path,
          'Path to a blacklist file',
          type: :io,
          required: false,
          default: nil
      opt :parameter_values_path,
          'Path to a JSON file to pull Parameter values from',
          type: :io,
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
    end
  else
    Trollop.options do
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
          type: :io,
          required: false,
          default: nil
      opt :profile_path,
          'Path to a profile file',
          type: :io,
          required: false,
          default: nil
      opt :blacklist_path,
          'Path to a blacklist file',
          type: :io,
          required: false,
          default: nil
      opt :parameter_values_path,
          'Path to a JSON file to pull Parameter values from',
          type: :io,
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
    end
  end
end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/BlockLength
