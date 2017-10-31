require 'zip_util'
require 's3_util'
require 'fileutils'

class CodePipelineUtil

  ##
  # return a string with the contents of the file within the artifact zip
  #
  def self.retrieve_files_within_input_artifact(codepipeline_event:,
                                                path_within_input_artifact: user_parameters(codepipeline_event))
    begin
      zip_path = retrieve_input_artifact codepipeline_event
      files_from_zip = ZipUtil.read_files_from_zip zip_path,
                                              path_within_input_artifact
    ensure
      cleanup zip_path
    end
    files_from_zip
  end

  ##
  # $lambdaLogger.log "audit_result2: #{lambda_inputs['CodePipeline.job']['data']['inputArtifacts']}"
  #
  # audit_result2: [
  #   {
  #     location={
  #       s3Location={
  #         bucketName=codepipeline-us-east-1-324320755747,
  #         objectKey=cfn-nag-example/MyApp/Dkh7wwX.zip
  #       },
  #       type=S3
  #     },
  #     revision=98dbfc107ef1221eb6c32f4f7015564456d670ec,
  #     name=MyApp
  #   }
  # ]
  def self.retrieve_input_artifact(codepipeline_event)
    input_artifact = input_artifact(codepipeline_event)

    s3util.retrieve_s3_object_content_to_tmp_file bucket_name: input_artifact['location']['s3Location']['bucketName'],
                                                  object_key: input_artifact['location']['s3Location']['objectKey']
  end

  private

  def self.cleanup(zip_path)
    FileUtils.rm zip_path unless zip_path.nil?
  end

  def self.s3util
    S3Util.new
  end

  def self.user_parameters(codepipeline_event)
    codepipeline_event['data']['actionConfiguration']['configuration']['UserParameters']
  end

  def self.input_artifact(codepipeline_event)
    unless codepipeline_event['data']['inputArtifacts'].size == 1
      raise 'Must have 1 and only 1 input artifact'
    end

    input_artifact = codepipeline_event['data']['inputArtifacts'].first

    if input_artifact['location']['type'] != 'S3'
      raise 'S3 is only type supported'
    end

    input_artifact
  end
end