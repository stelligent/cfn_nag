##### inline ingress
warning jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::EC2::SecurityGroup" and (.Properties.SecurityGroupIngress|type == "object"))|select(.Properties.SecurityGroupIngress.CidrIp? == "0.0.0.0/0")]|map(.LogicalResourceId)',
        message: 'Security Groups found with cidr open to world on ingress.  This should never be true on instance.  Permissible on ELB'

warning jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::EC2::SecurityGroup" and (.Properties.SecurityGroupIngress|type == "array"))|first(select(.Properties.SecurityGroupIngress[].CidrIp? == "0.0.0.0/0"))]|map(.LogicalResourceId)',
        message: 'Security Groups found with cidr open to world on ingress array.  This should never be true on instance.  Permissible on ELB'

##### external ingress
warning jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::EC2::SecurityGroupIngress")|select(.Properties.CidrIp? == "0.0.0.0/0")]|map(.LogicalResourceId)',
        message: 'Security Group Standalone Ingress found with cidr open to world. This should never be true on instance.  Permissible on ELB'


###### inline egress
warning jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::EC2::SecurityGroup" and (.Properties.SecurityGroupEgress|type == "object"))|select(.Properties.SecurityGroupEgress.CidrIp? == "0.0.0.0/0")]|map(.LogicalResourceId)',
        message: 'Security Groups found with cidr open to world on egress'


warning jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::EC2::SecurityGroup" and (.Properties.SecurityGroupEgress|type == "array"))|first(select(.Properties.SecurityGroupEgress[].CidrIp? == "0.0.0.0/0"))]|map(.LogicalResourceId)',
        message: 'Security Groups found with cidr open to world on egress array'


##### external egress
warning jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::EC2::SecurityGroupEgress")|select(.Properties.CidrIp? == "0.0.0.0/0")]|map(.LogicalResourceId)',
        message: 'Security Group Standalone Egress found with cidr open to world.'


# BEWARE with escapes \d -> \\\d because of how the escapes get munged from ruby through to shell
warning jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::EC2::SecurityGroupIngress" and .Properties.CidrIp|type == "string")|select(.Properties.CidrIp | test("^\\\d{1,3}\\\.\\\d{1,3}\\\.\\\d{1,3}\\\.\\\d{1,3}/(?!32)$") )]|map(.LogicalResourceId)',
        message: 'Security Group Standalone Ingress cidr found that is not /32'


warning jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::EC2::SecurityGroup" and (.Properties.SecurityGroupIngress|type == "object"))|select(.Properties.SecurityGroupIngress.CidrIp|type == "string")|select(.Properties.SecurityGroupIngress.CidrIp | test("^\\\d{1,3}\\\.\\\d{1,3}\\\.\\\d{1,3}\\\.\\\d{1,3}/(?!32)$") )]|map(.LogicalResourceId)',
        message: 'Security Groups found with cidr that is not /32'


warning jq: '[.Resources|with_entries(.value.LogicalResourceId = .key)[] | select(.Type == "AWS::EC2::SecurityGroup" and (.Properties.SecurityGroupIngress|type == "array"))|select(.Properties.SecurityGroupIngress[].CidrIp|type == "string")|select(.Properties.SecurityGroupIngress[].CidrIp | if .|type=="string" then test("^\\\d{1,3}\\\.\\\d{1,3}\\\.\\\d{1,3}\\\.\\\d{1,3}/(?!32)$") else false end)]|map(.LogicalResourceId)',
        message: 'Security Groups found with cidr that is not /32'


#for inline, this covers it, but with an externalized egress rule... the expression gets real evil
#i guess the ideal would be to do a join of ingress and egress rules with the parent sg
#but it gets real hairy with FnGetAtt for GroupId and all that.... think it best to
#write some imperative code in custom rules to take care of things
# violation '.Resources[]|select(.Type == "AWS::EC2::SecurityGroup")|select(.Properties.SecurityGroupEgress == null or .Properties.SecurityGroupEgress.length? == 0)' do |security_groups|
#   puts "Security Groups found without egress json_rules: #{security_groups}"
# end