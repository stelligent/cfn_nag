class RuleDefinition
  WARNING = 'WARN'.freeze
  FAILING_VIOLATION = 'FAIL'.freeze

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

  def ==(other_violation)
    other_violation.class == self.class && other_violation.to_h == to_h
  end
end
