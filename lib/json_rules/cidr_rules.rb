##### inline ingress
warning id: 'W2',
        jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::EC2::SecurityGroup" and (.Properties.SecurityGroupIngress|type == "object"))|select(.Properties.SecurityGroupIngress.CidrIp? == "0.0.0.0/0")]|map(.LogicalResourceId)',
        message: 'Security Groups found with cidr open to world on ingress.  This should never be true on instance.  Permissible on ELB'

warning id: 'W3',
        jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::EC2::SecurityGroup" and (.Properties.SecurityGroupIngress|type == "array"))|first(select(.Properties.SecurityGroupIngress[].CidrIp? == "0.0.0.0/0"))]|map(.LogicalResourceId)',
        message: 'Security Groups found with cidr open to world on ingress array.  This should never be true on instance.  Permissible on ELB'

##### external ingress
warning id: 'W4',
        jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::EC2::SecurityGroupIngress")|select(.Properties.CidrIp? == "0.0.0.0/0")]|map(.LogicalResourceId)',
        message: 'Security Group Standalone Ingress found with cidr open to world. This should never be true on instance.  Permissible on ELB'


###### inline egress
warning id: 'W5',
        jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::EC2::SecurityGroup" and (.Properties.SecurityGroupEgress|type == "object"))|select(.Properties.SecurityGroupEgress.CidrIp? == "0.0.0.0/0")]|map(.LogicalResourceId)',
        message: 'Security Groups found with cidr open to world on egress'


warning id: 'W6',
        jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::EC2::SecurityGroup" and (.Properties.SecurityGroupEgress|type == "array"))|first(select(.Properties.SecurityGroupEgress[].CidrIp? == "0.0.0.0/0"))]|map(.LogicalResourceId)',
        message: 'Security Groups found with cidr open to world on egress array'


##### external egress
warning id: 'W7',
        jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::EC2::SecurityGroupEgress")|select(.Properties.CidrIp? == "0.0.0.0/0")]|map(.LogicalResourceId)',
        message: 'Security Group Standalone Egress found with cidr open to world.'


# BEWARE with escapes \d -> \\\d because of how the escapes get munged from ruby through to shell
warning id: 'W8',
        jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::EC2::SecurityGroupIngress") | if(.Properties.CidrIp|type == "string") then select(.Properties.CidrIp|endswith("/32")|not) else (select(.Properties.CidrIp[]|endswith("/32")|not)) end ]|map(.LogicalResourceId)',
        message: 'Security Group Standalone Ingress cidr found that is not /32'

non_32_cidr_jq_expression = <<END
[.Resources |
 with_entries(.value.LogicalResourceId = .key)[] |
 select(.Type == "AWS::EC2::SecurityGroup") |
 if (.Properties.SecurityGroupIngress|type == "object")
 then (
        select(.Properties.SecurityGroupIngress.CidrIp|endswith("/32")|not)
      )
 else (
        if (.Properties.SecurityGroupIngress|type == "array")
        then (
               select(.Properties.SecurityGroupIngress[]|select(.CidrIp|endswith("/32")|not))
             )
        else empty
        end
      )
  end
  ]|map(.LogicalResourceId)
END

warning id: 'W9',
        jq: non_32_cidr_jq_expression,
        message: 'Security Groups found with cidr that is not /32'
