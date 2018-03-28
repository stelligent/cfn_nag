require 'spec_helper'
require 's3_util'

describe S3Util, :s3 do
  before(:each) do
    @stubbed_s3 = Aws::S3::Client.new(stub_responses: true)
    @s3_util = S3Util.new
    expect(@s3_util).to receive(:s3)
      .and_return(@stubbed_s3)
      .at_least(:once)
  end

  describe '#retrieve_s3_object_content_to_tmp_file' do
    ##
    # this doesn't cover missing bucket i don't think
    # maybe just let it rip
    # the SDK exceptions don't describe what is missing
    # so maybe better to rethrow?
    ##
    context 'when the object does not exist' do
      before(:each) do
        @stubbed_s3.stub_responses(
          :get_bucket_location,
          location_constraint: 'us-west-2'
        )
        @stubbed_s3.stub_responses(:get_object, 'NotFound')
      end

      it 'raises an error' do
        expect do
          _ = @s3_util.retrieve_s3_object_content_to_tmp_file \
            bucket_name: 'arealbucket',
            object_key: 'some_object_key_that_shall_never_be_found'
        end.to raise_error Aws::S3::Errors::NotFound
      end
    end

    context 'when the object exists in bucket' do
      before(:each) do
        @stubbed_s3.stub_responses(
          :get_bucket_location,
          location_constraint: 'us-west-2'
        )
        @stubbed_s3.stub_responses(
          :get_object,
          body: 'fredfredfred'
        )
      end

      it 'writes the object to a local tmp file' do
        actual_temp_file_path = \
          @s3_util.retrieve_s3_object_content_to_tmp_file \
            bucket_name: 'bucket_with_zips',
            object_key: 'some_object_key'
        expect(IO.read(actual_temp_file_path)).to eq 'fredfredfred'
      end
    end
  end

  describe '#bucket_region' do
    context 'when bucket location is blank' do
      before(:each) do
        @stubbed_s3.stub_responses(
          :get_bucket_location,
          location_constraint: ''
        )
      end

      it 'returns us-east-1 region' do
        actual_region = @s3_util.bucket_region 'some_bucket'
        expected_region = 'us-east-1'

        expect(actual_region).to eq expected_region
      end
    end

    context 'when bucket location is EU' do
      before(:each) do
        @stubbed_s3.stub_responses(
          :get_bucket_location,
          location_constraint: 'EU'
        )
      end

      it 'returns eu-west-1 region' do
        actual_region = @s3_util.bucket_region 'some_bucket'
        expected_region = 'eu-west-1'

        expect(actual_region).to eq expected_region
      end
    end
  end
end
