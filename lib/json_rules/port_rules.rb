warning jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::EC2::SecurityGroup" and (.Properties.SecurityGroupIngress|type == "object"))|select(.Properties.SecurityGroupIngress.ToPort != .Properties.SecurityGroupIngress.FromPort)]|map(.LogicalResourceId)',
        message:  'Security Groups found ingress with port range instead of just a single port'

warning jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::EC2::SecurityGroup" and (.Properties.SecurityGroupIngress|type == "array"))|select([.Properties.SecurityGroupIngress[].ToPort] != [.Properties.SecurityGroupIngress[].FromPort])]|map(.LogicalResourceId)',
        message:  'Security Groups found ingress with port range instead of just a single port'

warning jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::EC2::SecurityGroup" and (.Properties.SecurityGroupEgress|type == "object"))|select(.Properties.SecurityGroupEgress.ToPort != .Properties.SecurityGroupEgress.FromPort)]|map(.LogicalResourceId)',
        message:  'Security Groups found egress with port range instead of just a single port'

warning jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::EC2::SecurityGroup" and (.Properties.SecurityGroupEgress|type == "array"))|select([.Properties.SecurityGroupEgress[].ToPort] != [.Properties.SecurityGroupEgress[].FromPort])]|map(.LogicalResourceId)',
        message:  'Security Groups found egress with port range instead of just a single port'

warning jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::EC2::SecurityGroupIngress")|select(.Properties.ToPort != .Properties.FromPort)]|map(.LogicalResourceId)',
        message:  'Security Groups found ingress with port range instead of just a single port'

warning jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::EC2::SecurityGroupEgress")|select(.Properties.ToPort != .Properties.FromPort)]|map(.LogicalResourceId)',
        message:  'Security Groups found egress with port range instead of just a single port'
