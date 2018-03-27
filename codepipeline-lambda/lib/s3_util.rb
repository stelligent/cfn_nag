require 'aws-sdk'
require 'tempfile'
require_relative 'clients'

# S3 utility methods
class S3Util
  include Clients

  ##
  # Stream the given S3 object to a file in /tmp/s3utilXXXXX
  #
  # @return the absolute path of temp file name (e.g. /tmp/s3utilXXXX)
  ##
  def retrieve_s3_object_content_to_tmp_file(bucket_name:, object_key:)
    bucket_region = bucket_region bucket_name

    tempfile = "/tmp/s3util#{Time.now.to_i}#{Time.now.to_i}"
    File.open(tempfile, 'wb') do |file|
      s3(region: bucket_region).get_object(bucket: bucket_name,
                                           key: object_key) do |chunk|
        file.write(chunk)
      end
    end

    tempfile
  end

  ##
  # Given an s3 bucket name, return the region/location for the bucket's storage
  ##
  def bucket_region(bucket_name)
    get_bucket_location_response = s3.get_bucket_location bucket: bucket_name
    bucket_region = get_bucket_location_response.location_constraint
    bucket_region = bucket_region == '' ? 'us-east-1' : bucket_region
    bucket_region == 'EU' ? 'eu-west-1' : bucket_region
  end
end
