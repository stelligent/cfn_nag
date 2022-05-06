# frozen_string_literal: true

require 'logging'

##
# This is really the traditional implementation for CustomRuleLoader
# that looks in cfn-nag/custom_rules and an optional directory of a
# client's choosing
#
class FileBasedRuleRepo
  def initialize(rule_directory, rule_directory_recursive: false)
    @rule_directory = rule_directory
    @rule_directory_recursive = rule_directory_recursive
    validate_extra_rule_directory rule_directory
  end

  def discover_rules
    rule_registry = RuleRegistry.new

    # we look on the file system, and we load from the file system into a Class
    # that the runtime can refer back to later from the registry which is effectively
    # just a set of rule definitons
    discover_rule_classes(@rule_directory,
                          rule_directory_recursive: @rule_directory_recursive).each do |rule_class|
      rule_registry.definition(rule_class)
    end

    rule_registry
  end

  private

  def validate_extra_rule_directory(rule_directory)
    return true if rule_directory.nil? || File.directory?(rule_directory)

    raise "Not a real directory #{rule_directory}"
  end

  def locate_rule_files(rule_directory, rule_directory_recursive)
    return Dir.glob(File.join(rule_directory, '**/*Rule.rb')).sort if rule_directory_recursive

    Dir[File.join(rule_directory, '*Rule.rb')].sort
  end

  def discover_rule_filenames(rule_directory, rule_directory_recursive: false)
    rule_filenames = []
    unless rule_directory.nil?
      rule_filenames += locate_rule_files(rule_directory, rule_directory_recursive)
    end
    rule_filenames += locate_rule_files(File.join(__dir__, '..', 'custom_rules'), rule_directory_recursive)

    # Windows fix when running ruby from Command Prompt and not bash
    rule_filenames.reject! { |filename| filename =~ /_rule.rb$/ }
    Logging.logger['log'].debug "rule_filenames: #{rule_filenames}"
    rule_filenames
  end

  def discover_rule_classes(rule_directory, rule_directory_recursive: false)
    rule_classes = []

    rule_filenames = discover_rule_filenames(
      rule_directory,
      rule_directory_recursive: rule_directory_recursive
    )
    rule_filenames.each do |rule_filename|
      require(File.absolute_path(rule_filename))
      rule_classname = File.basename(rule_filename, '.rb')

      rule_classes << Object.const_get(rule_classname)
    end
    Logging.logger['log'].debug "rule_classes: #{rule_classes}"

    rule_classes
  end
end
