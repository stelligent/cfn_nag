require 'violation'

violation id: 'F666',
          jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::EC2::InternetGateway") ]| map(.LogicalResourceId) ',
          message: 'Internet Gateways are not allowed'