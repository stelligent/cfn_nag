# require 'cfn-nag/violation'
# require 'model/action_parser'
#
# class UnencryptedS3PutObjectAllowedRule
#
#   def rule_text
#     'It appears that the S3 Bucket Policy allows s3:PutObject without server-side encryption'
#   end
#
#   def rule_type
#     Violation::WARNING
#   end
#
#   def rule_id
#     'W1000'
#   end
#
#   def audit(cfn_model)
#     logical_resource_ids = []
#     cfn_model.bucket_policies.each do |bucket_policy|
#       found_statement = bucket_policy.statements.find do |statement|
#         blocks_put_object_without_encryption(statement)
#       end
#       if found_statement.nil?
#         logical_resource_ids << bucket_policy.logical_resource_id
#       end
#     end
#
#     if logical_resource_ids.size > 0
#       Violation.new(id: rule_id,
#                     type: rule_type,
#                     message: rule_text,
#                     logical_resource_ids: logical_resource_ids)
#     else
#       nil
#     end
#   end
#
#   private
#
#   def blocks_put_object_without_encryption(statement)
#     encryption_condition = {
#       'StringNotEquals' => {
#         's3:x-amz-server-side-encryption' => 'AES256'
#       }
#     }
#
#     # this isn't quite complete.  parsing the Resource field can be tricky
#     # looking for a trailing wildcard will likely be right most of the time
#     # but there are a lot of string manipulations to confuse things so...
#     # just warn when we can't find at least the Deny+encryption - they may have an
#     # incomplete Deny (for encryption) and that will slip through
#     statement['Effect'] == 'Deny' and
#         ActionParser.new.include?(actual_action: statement['Action'], action_to_look_for: 's3:PutObject') and
#         S3BucketPolicy::condition_includes?(statement, encryption_condition) and
#         statement['Principal'] == '*'
#   end
# end
