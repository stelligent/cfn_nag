# frozen_string_literal: true

require 'cfn-nag/profile_loader'
require 'cfn-nag/deny_list_loader'

module ViolationFiltering
  def filter_violations_by_profile(profile_definition:, rule_definitions:, violations:)
    profile = nil
    unless profile_definition.nil?
      begin
        profile = ProfileLoader.new(rule_definitions)
                               .load(profile_definition: profile_definition)
      rescue StandardError => profile_load_error
        raise "Profile loading error: #{profile_load_error}"
      end
    end

    violations.reject do |violation|
      !profile.nil? && !profile.contains_rule?(violation.id)
    end
  end

  def filter_violations_by_deny_list(deny_list_definition:, rule_definitions:, violations:)
    deny_list = nil
    unless deny_list_definition.nil?
      begin
        deny_list = DenyListLoader.new(rule_definitions)
                                  .load(deny_list_definition: deny_list_definition)
      rescue StandardError => deny_list_load_error
        raise "Deny list loading error: #{deny_list_load_error}"
      end
    end

    violations.reject do |violation|
      !deny_list.nil? && deny_list.contains_rule?(violation.id)
    end
  end
end
