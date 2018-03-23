require 'aws-sdk'

# CodePipeline Client container
module Clients
  def codepipeline
    Aws::CodePipeline::Client.new
  end

  def s3(region: nil)
    if region.nil? || region.empty?
      Aws::S3::Client.new
    else
      Aws::S3::Client.new(region: region)
    end
  end
end
