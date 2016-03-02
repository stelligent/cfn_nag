require 'spec_helper'
require 'model/s3_bucket_policy_parser'
require 'json'

describe S3BucketPolicyParser do

  describe 'parse' do
    context 'bucket policy with array of statements' do
      it 'returns true' do
        bucket_policy_source = <<-END
          {
            "Type": "AWS::S3::BucketPolicy",
            "Properties": {
              "Bucket": {
                "Ref": "S3Bucket2"
              },
              "PolicyDocument": {
                "Statement": [
                  {
                    "Action": [
                      "s3:*"
                    ],
                    "Effect": "Allow",
                    "Resource": "arn:aws:s3:::fakebucketfakebucket2/*",
                    "Principal": {
                      "AWS": "*"
                    }
                  }
                ]
              }
            }
          }
        END

        s3_bucket_policy = S3BucketPolicyParser.new.parse 'someId', JSON.parse(bucket_policy_source)
        expect(s3_bucket_policy.logical_resource_id).to eq 'someId'
        expect(s3_bucket_policy.statements.size).to eq 1
        expect(s3_bucket_policy.statements.first['Effect']).to eq 'Allow'
        expect(s3_bucket_policy.statements.first['Resource']).to eq 'arn:aws:s3:::fakebucketfakebucket2/*'
        expect(s3_bucket_policy.statements.first['Action']).to eq ['s3:*']
        expect(s3_bucket_policy.statements.first['Principal']).to eq({ 'AWS' => '*'})
      end
    end

    context 'bucket policy with one statement' do
      it 'returns true' do
        bucket_policy_source = <<-END
          {
            "Type": "AWS::S3::BucketPolicy",
            "Properties": {
              "Bucket": {
                "Ref": "S3Bucket2"
              },
              "PolicyDocument": {
                "Statement":
                  {
                    "Action": [
                      "s3:*"
                    ],
                    "Effect": "Allow",
                    "Resource": "arn:aws:s3:::fakebucketfakebucket2/*",
                    "Principal": {
                      "AWS": "*"
                    }
                  }

              }
            }
          }
        END

        s3_bucket_policy = S3BucketPolicyParser.new.parse 'someId', JSON.parse(bucket_policy_source)
        expect(s3_bucket_policy.logical_resource_id).to eq 'someId'
        expect(s3_bucket_policy.statements.size).to eq 1
        expect(s3_bucket_policy.statements.first['Effect']).to eq 'Allow'
        expect(s3_bucket_policy.statements.first['Resource']).to eq 'arn:aws:s3:::fakebucketfakebucket2/*'
        expect(s3_bucket_policy.statements.first['Action']).to eq ['s3:*']
        expect(s3_bucket_policy.statements.first['Principal']).to eq({ 'AWS' => '*'})
      end
    end
  end
end
