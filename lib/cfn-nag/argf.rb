# frozen_string_literal: true

class Argf
  def self.for(type)
    case type
    when 'argf'
      ARGF
    when 'force'
      ForceArgf.new
    else
      raise "Unsupported Argf type #{type}; prefer 'argf' or use 'force'"
    end
  end
end

class ForceArgf
  def use_file(test_file:)
    @f = File.new(test_file, 'r')
  end

  def file
    @f
  end

  def closed?
    @f.closed?
  end

  def eof?
    @f.eof?
  end

  def close
    @f.close
  end
end
