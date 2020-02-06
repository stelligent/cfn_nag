# frozen_string_literal: true

class CfnNagConfig
  # rubocop:disable Metrics/ParameterLists
  def initialize(profile_definition: nil,
                 blacklist_definition: nil,
                 rule_directory: nil,
                 allow_suppression: true,
                 print_suppression: false,
                 isolate_custom_rule_exceptions: false,
                 fail_on_warnings: false,
                 rule_repository_definitions: [])
    @rule_directory = rule_directory
    @custom_rule_loader = CustomRuleLoader.new(
      rule_directory: rule_directory,
      allow_suppression: allow_suppression,
      print_suppression: print_suppression,
      isolate_custom_rule_exceptions: isolate_custom_rule_exceptions,
      rule_repository_definitions: rule_repository_definitions
    )
    @profile_definition = profile_definition
    @blacklist_definition = blacklist_definition
    @fail_on_warnings = fail_on_warnings
    @rule_repositories = rule_repositories
  end
  # rubocop:enable Metrics/ParameterLists

  attr_reader :rule_directory
  attr_reader :custom_rule_loader
  attr_reader :profile_definition
  attr_reader :blacklist_definition
  attr_reader :fail_on_warnings
  attr_reader :rule_repositories
end
