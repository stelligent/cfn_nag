# frozen_string_literal: true

require 'json'

# View rules warnings/failings
class RulesView
  def emit(rule_registry, profile, output_format: 'txt')
    warnings = select_rules(rule_registry.warnings, profile)
    failings = select_rules(rule_registry.failings, profile)
    rules = failings + warnings
    case output_format
    when 'csv'
      emit_csv(rules)
    when 'json'
      puts rules_to_json(rules)
    when 'txt'
      emit_txt(warnings, failings)
    end

    if rule_registry.duplicate_ids?
      emit_duplicates(rule_registry.duplicate_ids)
      exit 1
    end
  end

  private

  def emit_txt(warnings, failings)
    output_pattern = '%<id>s %<message>s'
    puts 'WARNING VIOLATIONS:'
    emit_rules(warnings, output_pattern)
    puts
    puts 'FAILING VIOLATIONS:'
    emit_rules(failings, output_pattern)
  end

  def emit_csv(rules)
    output_pattern = '%<type>s,%<id>s,"%<message>s"'
    puts 'Type,ID,Message'
    emit_rules(rules, output_pattern)
  end

  def emit_duplicates(duplicates)
    duplicates.each do |info|
      puts '------------------'
      puts "Rule ID conflict detected for #{info[:id]}."
      puts "New rule: #{info[:new_message]}"
      puts "Registered rule: #{info[:registered_message]}"
    end
  end

  def select_rules(rules, profile)
    selected = if profile.nil?
                 rules
               else
                 rules.select { |rule| profile.contains_rule?(rule.id) }
               end
    selected.sort { |left, right| sort_id(left, right) }
  end

  def emit_rules(rules, output_pattern)
    rules.each do |rule|
      puts format(output_pattern, id: rule.id, message: rule.message, type: rule.type)
    end
  end

  def rules_to_json(rules)
    rule_array = []
    rules.each do |rule|
      rule_array << rule.to_h
    end
    puts JSON.pretty_generate(rule_array)
  end

  def sort_id(left, right)
    if left.id.match(/[FW][0-9]+/) && right.id.match(/[FW][0-9]+/)
      left.id[1..-1].to_i <=> right.id[1..-1].to_i
    else
      left.id <=> right.id
    end
  end
end
