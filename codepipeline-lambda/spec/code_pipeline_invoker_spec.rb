require 'spec_helper'
require 'json'
require 'code_pipeline_invoker'
require 'code_pipeline_util'

describe CodePipelineInvoker do
  before(:each) do
    $lambdaInputMap = {
      'CodePipeline.job' => {
        'id' => '1234'
      }
    }
    expect($lambdaContext).to receive(:getAwsRequestId)
                          .and_return '1234'

    @stubbed_codepipeline = Aws::CodePipeline::Client.new(stub_responses: true)
    @stubbed_codepipeline.stub_responses(:put_job_failure_result, {})
    @stubbed_codepipeline.stub_responses(:put_job_success_result, {})

    @code_pipeline_invoker = CodePipelineInvoker.new

    allow(@code_pipeline_invoker).to receive(:log) { |message| puts message }

    allow(@code_pipeline_invoker).to receive(:codepipeline)
                                 .and_return(@stubbed_codepipeline)
  end

  context 'when the audit raises an error' do
    it 'marks the job result as a failure' do


      expect(@code_pipeline_invoker).to receive(:audit_impl)
                                    .and_raise('cause a failure')

      # this expectatoin is what we care most about
      expect(@stubbed_codepipeline).to receive(:put_job_failure_result)
                                   .exactly(1)
                                   .times

      # expectations are above us
      @code_pipeline_invoker.audit
    end
  end

  context 'when there are failing violations' do
    it 'marks the job result as a success' do
      expect(CodePipelineUtil).to receive(:retrieve_files_within_input_artifact)
                              .with(any_args)
                              .and_return(json_templates_zip_file_contents)

      # this expectatoin is what we care most about
      expect(@stubbed_codepipeline).to receive(:put_job_failure_result)
                                   .exactly(1)
                                   .times

      # expectations are above us
      @code_pipeline_invoker.audit
    end
  end

  context 'when there are no failing violations' do
    it 'marks the job result as a failure' do
      expect(CodePipelineUtil).to receive(:retrieve_files_within_input_artifact)
                              .with(any_args)
                              .and_return(no_violations_cfn_templates)

      # this expectatoin is what we care most about
      expect(@stubbed_codepipeline).to receive(:put_job_success_result)
                                   .exactly(1)
                                   .times

      # expectations are above us
      @code_pipeline_invoker.audit
    end
  end
end