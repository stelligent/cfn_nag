violation id: 'F1',
          jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::EC2::Volume")|'\
              'select(.Properties.Encrypted == null or .Properties.Encrypted == false)]|map(.LogicalResourceId) ',
          message: 'EBS volume should have server-side encryption enabled'