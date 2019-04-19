# frozen_string_literal: true

require 'cfn-nag/profile_loader'
require 'cfn-nag/blacklist_loader'

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

  def filter_violations_by_blacklist(blacklist_definition:, rule_definitions:, violations:)
    blacklist = nil
    unless blacklist_definition.nil?
      begin
        blacklist = BlackListLoader.new(rule_definitions)
                                   .load(blacklist_definition: blacklist_definition)
      rescue StandardError => blacklist_load_error
        raise "Blacklist loading error: #{blacklist_load_error}"
      end
    end

    violations.reject do |violation|
      !blacklist.nil? && blacklist.contains_rule?(violation.id)
    end
  end
end
