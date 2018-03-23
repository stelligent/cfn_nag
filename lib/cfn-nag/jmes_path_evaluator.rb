require 'jmespath'
require 'logging'

##
# THIS DOES NOT RESPECT SUPPRESSIONS!!!!!!
##
class JmesPathEvaluator
  def initialize(cfn_model)
    @cfn_model = cfn_model
    @warnings = []
    @failures = []
  end

  def warning(id:, jmespath:, message:)
    violation id: id,
              jmespath: jmespath,
              message: message,
              violation_type: Violation::WARNING
  end

  def failure(id:, jmespath:, message:)
    violation id: id,
              jmespath: jmespath,
              message: message,
              violation_type: Violation::FAILING_VIOLATION
  end

  def violations
    @warnings + @failures
  end

  private

  def violation(id:, jmespath:, message:, violation_type:)
    Logging.logger['log'].debug jmespath

    logical_resource_ids = JMESPath.search(jmespath,
                                           flatten(@cfn_model.raw_model))

    unless logical_resource_ids.empty?
      @warnings << Violation.new(id: id,
                                 type: violation_type,
                                 message: message,
                                 logical_resource_ids: logical_resource_ids)
    end
  end

  def flatten(hash)
    hash['Resources'].each do |logical_resource_id, resource|
      resource['id'] = logical_resource_id
    end
    hash
  end
end
