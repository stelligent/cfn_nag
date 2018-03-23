class RulesView
  def emit(rule_registry, profile)
    puts 'WARNING VIOLATIONS:'
    rule_registry.warnings.sort { |left, right| sort_id(left, right) }.each do |warning|
      if profile.nil?
        puts "#{warning.id} #{warning.message}"
      else
        puts "#{warning.id} #{warning.message}" if profile.execute_rule?(warning.id)
      end
    end
    puts
    puts 'FAILING VIOLATIONS:'
    rule_registry.failings.sort { |left, right| sort_id(left, right) }.each do |failing|
      if profile.nil?
        puts "#{failing.id} #{failing.message}"
      else
        puts "#{failing.id} #{failing.message}" if profile.execute_rule?(failing.id)
      end
    end
  end

  private

  def sort_id(left, right)
    if left.id.match(/[FW][0-9]+/) && right.id.match(/[FW][0-9]+/)
      left.id[1..-1].to_i <=> right.id[1..-1].to_i
    else
      left.id <=> right.id
    end
  end
end
