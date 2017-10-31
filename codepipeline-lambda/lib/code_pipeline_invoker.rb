require 'cfn-nag'
require_relative 'code_pipeline_util'
require_relative 'clients'
require_relative 'plain_text_results'
require_relative 'plain_text_summary'

class CodePipelineInvoker
  include Clients

  def audit
    begin
      job_id = lambda_inputs['CodePipeline.job']['id']
      log "job_id: #{job_id}"

      audit_impl job_id
    rescue Exception => e
      log "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
      codepipeline.put_job_failure_result job_id: job_id,
                                          failure_details: {
                                            type: 'JobFailed',
                                            message: "Error executing cfn-nag: #{e}",
                                            external_execution_id: $lambdaContext.getAwsRequestId
                                          }
    end
  end

  def lambda_inputs
    $lambdaInputMap
  end

  def log(message)
    $lambdaLogger.log message
  end

  private

  def audit_impl(job_id)
    cloudformation_entries = CodePipelineUtil.retrieve_files_within_input_artifact codepipeline_event: lambda_inputs['CodePipeline.job']
    log "cloudformation_entries: #{cloudformation_entries}"

    cfn_nag = CfnNag.new

    audit_results = cloudformation_entries.map do |cloudformation_entry|
      audit_result = cfn_nag.audit cloudformation_string: cloudformation_entry[:contents]

      {
        name: cloudformation_entry[:name],
        audit_result: audit_result
      }
    end

    put_job_result job_id, audit_results
  end

  def put_job_result(job_id,
                     audit_results)

    log PlainTextResults.new.render audit_results

    audit_results_summary = PlainTextSummary.new.render audit_results

    if audit_results.find { |audit_result| audit_result[:audit_result][:failure_count] > 0 }
      codepipeline.put_job_failure_result job_id: job_id,
                                          failure_details: {
                                            type: 'JobFailed',
                                            message: audit_results_summary,
                                            external_execution_id: $lambdaContext.getAwsRequestId
                                          }
    else
      codepipeline.put_job_success_result job_id: job_id,
                                          execution_details: {
                                            summary: audit_results_summary,
                                            external_execution_id: $lambdaContext.getAwsRequestId
                                          }
    end
  end
end
