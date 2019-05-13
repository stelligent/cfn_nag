# frozen_string_literal: true

require 'trollop'

# rubocop:disable Metrics/BlockLength
# rubocop:disable Metrics/AbcSize
# rubocop:disable Metrics/MethodLength
def cli_options(require_input_path: false)
  Trollop.options do
    version Gem::Specification.find_by_name('cfn-nag').version
    input_path_message = 'CloudFormation template to nag on or directory of ' \
                         'templates.  Default is all *.json, *.yaml, *.yml ' \
                         'and *.template recursively, but can be constrained ' \
                         'by --template-pattern'

    custom_rule_exceptions_message = 'Isolate custom rule exceptions - just ' \
                                     'emit the exception without stack trace ' \
                                     'and keep chugging'

    template_pattern_message = 'Within the --input-path, match files to scan ' \
                               'against this regular expression'

    opt :allow_suppression,
        'Allow using Metadata to suppress violations',
        type: :boolean,
        required: false,
        default: true
    opt :blacklist_path,
        'Path to a blacklist file',
        type: :io,
        required: false,
        default: nil
    opt :debug,
        'Enable debug output',
        type: :boolean,
        required: false,
        default: false
    opt :fail_on_warnings,
        'Treat warnings as failing violations',
        type: :boolean,
        required: false,
        default: false
    opt :input_path,
        input_path_message,
        type: :io,
        required: require_input_path
    opt :isolate_custom_rule_exceptions,
        custom_rule_exceptions_message,
        type: :boolean,
        required: false,
        default: false
    opt :output_format,
        'Format of results: [txt, json]',
        type: :string,
        default: 'txt'
    opt :parameter_values_path,
        'Path to a JSON file to pull Parameter values from',
        type: :io,
        required: false,
        default: nil
    opt :print_suppression,
        'Emit suppressions to stderr',
        type: :boolean,
        required: false,
        default: false
    opt :profile_path,
        'Path to a profile file',
        type: :io,
        required: false,
        default: nil
    opt :rule_directory,
        'Extra rule directory',
        type: :io,
        required: false,
        default: nil
    opt :template_pattern,
        template_pattern_message,
        type: :string,
        required: false,
        default: '..*\.json|..*\.yaml|..*\.yml|..*\.template'
  end
end
# rubocop:enable Metrics/MethodLength
# rubocop:enable Metrics/AbcSize
# rubocop:enable Metrics/BlockLength
