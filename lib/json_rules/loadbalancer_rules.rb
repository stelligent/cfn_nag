warning jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::ElasticLoadBalancing::LoadBalancer")|'\
              'select(.Properties.AccessLoggingPolicy == null)]|map(.LogicalResourceId) ',
        message: 'Elastic Load Balancer should have access logging configured'

warning jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::ElasticLoadBalancing::LoadBalancer")|'\
              'select(.Properties.AccessLoggingPolicy?.Enabled == false)]|map(.LogicalResourceId) ',
        message: 'Elastic Load Balancer should have access logging enabled'