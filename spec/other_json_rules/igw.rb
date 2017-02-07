require 'violation'

violation jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::EC2::InternetGateway") ]| map(.LogicalResourceId) ',
          message: 'Internet Gateways are not allowed'