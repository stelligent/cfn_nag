require 'spec_helper'
require 'model/s3_bucket_policy'
require 'json'

describe S3BucketPolicy do

  describe 'condition_includes?' do
    context 'statement with no conditions' do
      it 'returns false' do
        statement_source = <<-END
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
        END
        condition_found = S3BucketPolicy.condition_includes?(JSON.parse(statement_source),
                                                             { 'StringNotEquals' => { 's3:x-amz-server-side-encryption' => 'AES256'}})
        expect(condition_found).to eq false
      end
    end

    context 'statement with array of conditions containing the condition' do
      it 'returns true' do
        statement_source = <<-END
          {
            "Action": [
              "s3:*"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::fakebucketfakebucket2/*",
            "Principal": {
              "AWS": "*"
            },
            "Condition": [
              {
                "StringNotEquals": {
                  "s3:x-amz-server-side-encryption" : "AES256"
                }
              }
            ]
          }
        END
        condition_found = S3BucketPolicy.condition_includes?(JSON.parse(statement_source),
                                                             { 'StringNotEquals' => { 's3:x-amz-server-side-encryption' => 'AES256'}})
        expect(condition_found).to eq true
      end
    end

    context 'statement with array of conditions not containing the condition' do
      it 'returns false' do
        statement_source = <<-END
          {
            "Action": [
              "s3:*"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::fakebucketfakebucket2/*",
            "Principal": {
              "AWS": "*"
            },
            "Condition": [
              {
                "StringNotEquals": {
                  "s3:x-amz-server-side-encryption" : "AES256"
                }
              }
            ]
          }
        END

        condition_found = S3BucketPolicy.condition_includes?(JSON.parse(statement_source),
                                                             { 'StringEquals' => 'foo'})
        expect(condition_found).to eq false
      end
    end

    context 'statement with one condition that matches' do
      it 'returns true' do
        statement_source = <<-END
          {
            "Action": [
              "s3:*"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::fakebucketfakebucket2/*",
            "Principal": {
              "AWS": "*"
            },
            "Condition":
              {
                "StringNotEquals": {
                  "s3:x-amz-server-side-encryption" : "AES256"
                }
              }

          }
        END

        condition_found = S3BucketPolicy.condition_includes?(JSON.parse(statement_source),
                                                             { 'StringNotEquals' => { 's3:x-amz-server-side-encryption' => 'AES256'}})
        expect(condition_found).to eq true
      end
    end
  end
end
