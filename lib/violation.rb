require 'json'

class Violation
  WARNING = 'WARN'
  FAILING_VIOLATION = 'FAIL'

  attr_reader :id, :type, :message, :logical_resource_ids, :violating_code

  def initialize(id:,
                 type:,
                 message:,
                 logical_resource_ids: nil,
                 violating_code: nil)
    @id = id
    @type = type
    @message = message
    @logical_resource_ids = logical_resource_ids
    @violating_code = violating_code

    fail if @type.nil?
    fail if @message.nil?
  end

  def to_s
    puts "#{@id} #{@type} #{@message} #{@logical_resource_ids} #{@violating_code}"
  end

  def to_h
    {
      id: @id,
      type: @type,
      message: @message,
      logical_resource_ids: @logical_resource_ids,
      violating_code: @violating_code
    }
  end

  def ==(other_violation)
    other_violation.class == self.class && other_violation.to_h == to_h
  end
end