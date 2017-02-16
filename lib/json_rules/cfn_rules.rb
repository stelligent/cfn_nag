warning id: 'W1',
        jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Metadata."AWS::CloudFormation::Authentication") ]|'\
              'map(.LogicalResourceId) ',
        message: 'Specifying credentials in the template itself is probably not the safest thing'