require 'set'

class Profile
  attr_reader :rule_ids

  def initialize
    @rule_ids = Set.new
  end

  def add_rule(rule_id)
    @rule_ids << rule_id
  end

  def execute_rule?(rule_id)
    @rule_ids.include? rule_id
  end
end
