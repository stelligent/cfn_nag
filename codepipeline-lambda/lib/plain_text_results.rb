require 'cfn-nag/violation'

class PlainTextResults

  def render(audit_results)
    @results = ''
    audit_results.each do |audit_result|
      (1..60).each { @results += '-' }
      @results += nl + audit_result[:name] + nl
      (1..60).each { @results += '-' }

      @results += nl
      @results += nl

      audit_result[:audit_result][:violations].each do |violation|
        message message_type: "#{violation.type} #{violation.id}",
                message: violation.message,
                logical_resource_ids: violation.logical_resource_ids
        @results += nl
      end
      @results += "Failures count: #{Violation.count_failures(audit_result[:audit_result][:violations])}#{nl}"
      @results += "Warnings count: #{Violation.count_warnings(audit_result[:audit_result][:violations])}#{nl}"
    end
    @results
  end

  private

  def message(message_type:,
              message:,
              logical_resource_ids: nil)

    if logical_resource_ids == []
      logical_resource_ids = nil
    end

    (1..60).each { @results += '-' }
    @results += nl
    @results += "| #{message_type.upcase}#{nl}"
    @results += "|#{nl}"
    @results += "| Resources: #{logical_resource_ids}#{nl}" unless logical_resource_ids.nil?
    @results += "|#{nl}" unless logical_resource_ids.nil?
    @results += "| #{message}#{nl}"
  end

  def nl
    "\n"
  end
end
