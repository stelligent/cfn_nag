class S3BucketPolicy
  attr_accessor :logical_resource_id

  attr_reader :statements

  def initialize
    @statements = []
  end

  def add_statement(statement_hash)
    statements << statement_hash
  end

  def self.condition_includes?(statement, condition_hash)
    if statement['Condition'].nil?
      false
    else
      if statement['Condition'].is_a? Hash
        statement['Condition'] == condition_hash
      else
        statement['Condition'].include? condition_hash
      end
    end
  end
end
