warning jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::S3::Bucket")|'\
              'select(.Properties.AccessControl? == "PublicRead")]|map(.LogicalResourceId) ',
        message: 'S3 Bucket likely should not have a public read acl'

violation jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::S3::Bucket")|'\
              'select(.Properties.AccessControl? == "PublicReadWrite")]|map(.LogicalResourceId) ',
          message: 'S3 Bucket should not have a public read-write acl'



s3_wildcard_action_filter = <<END
def s3_wildcard_action:
  if .Statement|type == "object"
  then select(.Statement.Effect == "Allow" and (if .Statement.Action|type=="string" then (.Statement.Action == "s3:*" or .Statement.Action == "*") else ((.Statement.Action|indices("s3:*")|length > 0) or (.Statement.Action|indices("*")|length > 0)) end))
  else select(.Statement[]|.Effect == "Allow" and (if .Action|type=="string" then (.Action == "s3:*" or .Action == "*") else ((.Action|indices("s3:*")|length > 0) or (.Action|indices("*")|length > 0)) end))
  end;
END

s3_wildcard_principal_filter = <<END
def s3_wildcard_principal:
  if .Statement|type == "object"
  then select(.Statement.Effect == "Allow" and (.Statement.Principal?|type=="string") and (.Statement.Principal == "*") )
  else select(.Statement[]|.Effect == "Allow" and ((.Principal?|type=="string") and (.Principal == "*")) )
  end;
END

s3_wildcard_aws_principal_filter = <<END
def s3_wildcard_aws_principal:
  if .Statement|type == "object"
  then select(.Statement.Effect == "Allow" and (.Statement.Principal?|type=="object") and (.Statement.Principal.AWS == "*"))
  else select(.Statement[]|(.Effect == "Allow" and (.Principal?|type=="object") and (.Principal.AWS == "*")))
  end;
END


violation jq: s3_wildcard_action_filter +
              "[#{resources_by_type('AWS::S3::BucketPolicy')}|select(.Properties.PolicyDocument|s3_wildcard_action)]|map(.LogicalResourceId) ",
          message: 'S3 Bucket policy should not allow * action'

violation jq: s3_wildcard_principal_filter +
              "[#{resources_by_type('AWS::S3::BucketPolicy')}|select(.Properties.PolicyDocument|s3_wildcard_principal)]|map(.LogicalResourceId) ",
          message: 'S3 Bucket policy should not allow * principal'

violation jq: s3_wildcard_aws_principal_filter +
              "[#{resources_by_type('AWS::S3::BucketPolicy')}|select(.Properties.PolicyDocument|s3_wildcard_aws_principal)]|map(.LogicalResourceId) ",
          message: 'S3 Bucket policy should not allow * AWS principal'