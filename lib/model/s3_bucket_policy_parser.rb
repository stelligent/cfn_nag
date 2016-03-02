require_relative 's3_bucket_policy'


class S3BucketPolicyParser

  def parse(resource_name, resource_json)
    properties = resource_json['Properties']
    bucket_policy = S3BucketPolicy.new

    bucket_policy.logical_resource_id = resource_name

    unless properties.nil?
      policy_document = properties['PolicyDocument']
      unless policy_document.nil?
        unless policy_document['Statement'].nil?
          if policy_document['Statement'].is_a? Array
            policy_document['Statement'].each { |statement | bucket_policy.add_statement(statement)}
          else
            bucket_policy.add_statement(policy_document['Statement'])
          end
        end
      end
    end

    bucket_policy
  end
end

