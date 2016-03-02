warning jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | '\
            'select(.Type == "AWS::EC2::SecurityGroup")| '\
            'if (.Properties.SecurityGroupIngress|type == "object") '\
            'then select(.Properties.SecurityGroupIngress.ToPort != .Properties.SecurityGroupIngress.FromPort) '\
            'else if (.Properties.SecurityGroupIngress|type == "array") '\
            '     then select([.Properties.SecurityGroupIngress[].ToPort] != [.Properties.SecurityGroupIngress[].FromPort]) '\
            '     else empty '\
            '     end '\
            'end '\
            ']|map(.LogicalResourceId)',
        message:  'Security Groups found ingress with port range instead of just a single port'

warning jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::EC2::SecurityGroupIngress")|select(.Properties.ToPort != .Properties.FromPort)]|map(.LogicalResourceId)',
        message:  'Security Group ingress with port range instead of just a single port'

warning jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | '\
            'select(.Type == "AWS::EC2::SecurityGroup")| '\
            'if (.Properties.SecurityGroupEgress|type == "object") '\
            'then select(.Properties.SecurityGroupEgress.ToPort != .Properties.SecurityGroupEgress.FromPort) '\
            'else if (.Properties.SecurityGroupEgress|type == "array") '\
            '     then select([.Properties.SecurityGroupEgress[].ToPort] != [.Properties.SecurityGroupEgress[].FromPort]) '\
            '     else empty '\
            '     end '\
            'end'\
            ']|map(.LogicalResourceId)',
        message:  'Security Groups found egress with port range instead of just a single port'

warning jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::EC2::SecurityGroupEgress")|select(.Properties.ToPort != .Properties.FromPort)]|map(.LogicalResourceId)',
        message:  'Security Group egress with port range instead of just a single port'
