require 'cfn-nag/violation'

# Plaintext summary of failures/warnings
class PlainTextSummary
  def render(audit_results)
    @results = ''
    warning_count = fail_count = 0
    audit_results.each do |audit_result|
      violations = audit_result[:audit_result][:violations]
      fail_count += Violation.count_failures violations
      warning_count += Violation.count_warnings violations
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
