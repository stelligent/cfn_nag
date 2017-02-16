warning id: 'W10',
        jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::CloudFront::Distribution")|'\
              'select(.Properties.DistributionConfig.Logging == null)]|map(.LogicalResourceId) ',
        message: 'CloudFront Distribution should enable access logging'