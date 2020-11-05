# frozen_string_literal: true

require 'yaml'
require_relative 'rule_repo_exception'

##
# This captures logic for instantiating the RuleRepo implementations
# and merging their rule registries.  This was baked into CustomRuleLoader
# but broken out for cfn_nag_rules to use as well
#
class RuleRepositoryLoader
  def merge(rule_registry, rule_repository_definitions)
    rule_repository_definitions.each do |rule_repository_definition|
      rule_registry.merge! rule_repository(rule_repository_definition).discover_rules
    end
    rule_registry
  end

  private

  def to_sym_keys(hash)
    sym_hash = {}
    hash.each do |k, v|
      sym_hash[k.to_sym] = v
    end
    sym_hash
  end

  def rule_repository(rule_repository_definition_str)
    rule_repository_definition = YAML.safe_load rule_repository_definition_str
    unless rule_repository_definition['repo_class_name']
      raise RuleRepoException.new(msg: 'Malformed repo definition: missing repo_class_name')
    end

    repo_class = class_from_name(rule_repository_definition['repo_class_name'])
    if rule_repository_definition['repo_arguments'].is_a?(Hash)
      repo_class.new(**to_sym_keys(rule_repository_definition['repo_arguments']))
    else
      repo_class.new
    end
  end

  def class_from_name(name)
    Object.const_get name
  rescue NameError
    raise RuleRepoException.new(msg: "Malformed repo definition: repo_class_name: #{name} not loaded")
  end
end
