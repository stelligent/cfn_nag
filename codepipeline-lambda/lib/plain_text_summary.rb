require 'cfn-nag/violation'

class PlainTextSummary

  def render(audit_results)
    @results = ''
    warning_count = 0
    fail_count = 0
    audit_results.each do |audit_result|
      fail_count += Violation.count_failures(audit_result[:audit_result][:violations])
      warning_count += Violation.count_warnings(audit_result[:audit_result][:violations])
    end
    @results += "Failures count: #{fail_count}#{nl}"
    @results += "Warnings count: #{warning_count}#{nl}"
    @results
  end

  private

  def nl
    "\n"
  end
end