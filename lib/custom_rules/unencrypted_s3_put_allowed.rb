require_relative '../violation'

class UnencryptedS3PutObjectAllowedRule

  def audit(cfn_model)
    logical_resource_ids = []
    cfn_model.bucket_policies.each do |bucket_policy|
      found_statement = bucket_policy.statements.find do |statement|
        blocks_put_object_without_encryption(statement)
      end
      if found_statement.nil?
        logical_resource_ids << bucket_policy.logical_resource_id
      end
    end

    if logical_resource_ids.size > 0
      Violation.new(type: Violation::WARNING,
                    message: 'It appears that the S3 Bucket Policy allows s3:PutObject without server-side encryption',
                    logical_resource_ids: logical_resource_ids)
    else
      nil
    end
  end

  def blocks_put_object_without_encryption(statement)
    encryption_condition = {
        'StringNotEquals' => {
            's3:x-amz-server-side-encryption' => 'AES256'
        }
    }

    if statement.effect == 'Deny' and
       ActionParser.new.include?(statement.action, 's3:PutObject') and
       statement.condition.include?(encryption_condition) and
       statement.principal == '*'

      statement.resource.is_bucket_wildcard?
    end
  end
end