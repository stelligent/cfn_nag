require 'spec_helper'
require 'code_pipeline_util'
require_relative 'factory'

describe CodePipelineUtil do
  describe '#retrieve_files_within_input_artifact' do
    context 'when there is one s3 zip artifact with matching glob' do
      it 'returns contents of matched files within the zip' do
        code_pipeline_event = {
          'data' => {
            'actionConfiguration' => {
              'configuration' => {
                'UserParameters' => 'spec/test_templates/json/ec2_volume/*.json'
              }
            }
          }
        }

        expect(CodePipelineUtil).to \
          receive(:retrieve_input_artifact).and_return 'spec/test_templates/' \
                                                       'json_templates.zip'
        expect(CodePipelineUtil).to receive(:cleanup) {}

        actual_file_contents = \
          CodePipelineUtil.retrieve_files_within_input_artifact \
            codepipeline_event: code_pipeline_event

        expect(actual_file_contents).to eq json_templates_zip_file_contents
      end
    end
  end

  describe '#retrieve_input_artifact' do
    context 'when there is one s3 artifact' do
      it 'retrieves the one artifact' do
        expected_zip_path = '/tmp/s3util1234'

        s3util_double = double('s3util')
        expect(s3util_double).to(
          receive(:retrieve_s3_object_content_to_tmp_file)
          .with(bucket_name: 'somebucket', object_key: 'somekey')
          .and_return(expected_zip_path)
        )

        expect(CodePipelineUtil).to \
          receive(:s3util).and_return(s3util_double)

        actual_zip_path = \
          CodePipelineUtil.retrieve_input_artifact(
            'data' => { 'inputArtifacts' =>
                        [{ 'location' =>
                           { 'type' => 'S3',
                             's3Location' => { 'bucketName' => 'somebucket',
                                               'objectKey' => 'somekey' } } }] }
          )
        expect(actual_zip_path).to eq expected_zip_path
      end
    end

    def self.retrieve_input_artifact(codepipeline_event)
      input_artifact = input_artifact(codepipeline_event)

      s3util.retrieve_s3_object_content_to_tmp_file \
        bucket_name: input_artifact['location']['s3Location']['bucketName'],
        object_key: input_artifact['location']['s3Location']['objectKey']
    end

    context 'when is there is zero, or > 1 artifact' do
      it 'raises an error' do
        expect do
          CodePipelineUtil.retrieve_input_artifact(
            'data' => {
              'inputArtifacts' => %(artifact1 artifact2)
            }
          )
        end.to raise_error 'Must have 1 and only 1 input artifact'
      end
    end

    context 'when is one non-s3 artifact' do
      it 'raises an error' do
        expect do
          CodePipelineUtil.retrieve_input_artifact(
            'data' => {
              'inputArtifacts' => [
                {
                  'location' => { 'type' => 'MadeupGit' }
                }
              ]
            }
          )
        end.to raise_error 'S3 is only type supported'
      end
    end
  end
end
