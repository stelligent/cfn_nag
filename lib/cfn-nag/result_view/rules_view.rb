# frozen_string_literal: true

# View rules warnings/failings
class RulesView
  def emit(rule_registry, profile)
    puts 'WARNING VIOLATIONS:'
    emit_warnings rule_registry.warnings, profile
    puts
    puts 'FAILING VIOLATIONS:'
    emit_failings rule_registry.failings, profile
  end

  private

  def emit_warnings(warnings, profile)
    warnings.sort { |left, right| sort_id(left, right) }.each do |warning|
      if profile.nil?
        puts "#{warning.id} #{warning.message}"
      elsif profile.execute_rule?(warning.id)
        puts "#{warning.id} #{warning.message}"
      end
    end
  end

  def emit_failings(failings, profile)
    failings.sort { |left, right| sort_id(left, right) }.each do |failing|
      if profile.nil?
        puts "#{failing.id} #{failing.message}"
      elsif profile.execute_rule?(failing.id)
        puts "#{failing.id} #{failing.message}"
      end
    end
  end

  def sort_id(left, right)
    if left.id.match(/[FW][0-9]+/) && right.id.match(/[FW][0-9]+/)
      left.id[1..-1].to_i <=> right.id[1..-1].to_i
    else
      left.id <=> right.id
    end
  end
end
