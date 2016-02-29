warning jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::S3::Bucket")|'\
              'select(.Properties.AccessControl? == "PublicRead")]|map(.LogicalResourceId) ',
        message: 'S3 Bucket likely should not have a public read acl'

violation jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::S3::Bucket")|'\
              'select(.Properties.AccessControl? == "PublicReadWrite")]|map(.LogicalResourceId) ',
          message: 'S3 Bucket should not have a public read-write acl'