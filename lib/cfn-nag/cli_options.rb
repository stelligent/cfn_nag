# frozen_string_literal: true

require 'trollop'

class Options
  def self.for(type)
    case type
    when 'cli'
      CliOptions.new
    when 'force'
      ForceOptions.new
    else
      raise "Unsupported Options type #{type}; use 'cli' or 'force'"
    end
  end
end

# rubocop:disable Metrics/ClassLength
class CliOptions
  # rubocop:disable Metrics/BlockLength
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def get(cfn_nag_scan: false)
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
end
# rubocop:enable Metrics/ClassLength

class ForceOptions
  # rubocop:disable Metrics/ParameterLists
  def set(input_path: nil,
          fail_on_warnings: false,
          blacklist_definition: nil,
          parameter_values_path: nil,
          profile_path: nil,
          output_format: 'txt')
    @result = {
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
  # rubocop:enable Metrics/ParameterLists

  def get(*)
    @result
  end
end
