warning id: 'W24',
        jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::Lambda::Permission")|'\
              'select(.Properties.Action != "lambda:InvokeFunction")]|map(.LogicalResourceId) ',
        message: 'Lambda permission beside InvokeFunction might not be what you want?  Not sure!?'

violation id: 'F13',
          jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::Lambda::Permission")|'\
              'select(.Properties.Principal == "*")]|map(.LogicalResourceId) ',
        message: 'Lambda permission principal should not be wildcard'