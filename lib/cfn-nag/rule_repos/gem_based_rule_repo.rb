# frozen_string_literal: true

require 'cfn-nag/base_rule'
require 'rubygems'

class GemBasedRuleRepo
  def discover_rules
    rule_registry = RuleRegistry.new

    rule_gem_names.each do |rule_gem_name|
      next unless load_gem_entrypoint(rule_gem_name)

      gem_path = Gem.loaded_specs[rule_gem_name].full_gem_path
      require_all_rb_files_in_gem gem_path, rule_gem_name
    end

    unless rule_gem_names.empty?
      ObjectSpace.each_object do |object|
        if derives_from_base_rule?(object) || (object.respond_to?(:cfn_nag_rule?) && object.cfn_nag_rule?)
          rule_registry.definition(object)
        end
      end
    end

    rule_registry
  end

  private

  def require_all_rb_files_in_gem(gem_path, rule_gem_name)
    Dir.glob("#{gem_path}/lib/#{rule_gem_name}/**/*.rb").sort.each do |rule_file|
      require rule_file
    end
  end

  def rule_gem_names
    rule_gem_specs.map(&:name)
  end

  def rule_gem_specs
    specs = []

    # https://github.com/rvm/rubygems-bundler can interfere here
    # if you happen to have a gemspec in the current working directory?
    # Bundle.setup runs and replaces a SpecSet in here instead of collection of Specification?
    Gem::Specification.each do |spec|
      specs << spec if spec.metadata && spec.metadata['cfn_nag_rules'] == 'true'
    end
    specs
  end

  def load_gem_entrypoint(rule_gem_name)
    require rule_gem_name
    true
  rescue LoadError
    $stderr.puts "Could not require #{rule_gem_name} - does the rule gem have a top level entry point?"
    false
  end

  def derives_from_base_rule?(object)
    object.respond_to?(:superclass) && object.superclass == CfnNag::BaseRule
  end
end
