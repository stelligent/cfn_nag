# frozen_string_literal: true

class RuleRepoException < StandardError
  def initialize(msg: 'Trouble loading a rule-repository')
    super
  end
end
