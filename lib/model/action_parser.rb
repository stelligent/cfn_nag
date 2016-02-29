require 'json'

class ActionParser

  def include?(actual_action:, action_to_look_for:)
    if actual_action.is_a? Array
      matches = actual_action.find do |single_action|
        match_potentially_wildcard_action(actual_action: single_action,
                                          action_to_look_for: action_to_look_for)
      end
      not matches.nil?
    elsif actual_action.is_a? String
      match_potentially_wildcard_action(actual_action: actual_action,
                                        action_to_look_for: action_to_look_for)
    else
      fail "actual_action needs to be a String or Array (of String),not : #{actual_action.class}"
    end
  end

  private

  def match_potentially_wildcard_action(actual_action:, action_to_look_for:)
    actual_action_regex = actual_action.gsub /\*/, '.*'
    match_position = Regexp.new(actual_action_regex) =~ action_to_look_for
    not match_position.nil?
  end
end