require_relative 'profile'

class ProfileLoader
  def initialize(rules_registry)
    @rules_registry = rules_registry
  end

  def load(profile_definition:)
    if profile_definition.nil? || (profile_definition.strip == '')
      raise 'Empty profile'
    end

    new_profile = Profile.new

    profile_definition.each_line do |line|
      rule_id = line.chomp
      rule_line_match = /^([a-zA-Z]*?[0-9]+)\s*(.*)/.match(rule_id)
      if !rule_line_match.nil?
        rule_id = rule_line_match.captures.first
        if @rules_registry.by_id(rule_id) == nil
          raise "#{rule_id} is not a legal rule identifier from: #{@rules_registry.rules.map { |rule| rule.id }}"
        else
          new_profile.add_rule rule_id
        end
      end
    end
    new_profile
  end
end
