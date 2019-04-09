# frozen_string_literal: true

class RuleDefinition
  WARNING = 'WARN'
  FAILING_VIOLATION = 'FAIL'

  attr_reader :id, :type, :message

  def initialize(id:,
                 type:,
                 message:)
    @id = id
    @type = type
    @message = message

    [@id, @type, @message].each do |required|
      raise 'No parameters to Violation constructor can be nil' if required.nil?
    end
  end

  def to_s
    "#{@id} #{@type} #{@message}"
  end

  def to_h
    {
      id: @id,
      type: @type,
      message: @message
    }
  end

  def ==(other)
    other.class == self.class && other.to_h == to_h
  end
end
