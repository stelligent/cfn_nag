warning '.Resources[] | select(.Type == "AWS::EC2::SecurityGroup")|select(.Properties.SecurityGroupIngress.CidrIp? == "0.0.0.0/0")' do |security_groups|
  message 'warning', 'Security Groups found with cidr open to world on ingress.  This should never be true on instance.  Permissible on ELB', security_groups
end

warning '.Resources[] | select(.Type == "AWS::EC2::SecurityGroup")|select(.Properties.SecurityGroupIngress|type == "array")|select(.Properties.SecurityGroupIngress[].CidrIp == "0.0.0.0/0")' do |security_groups|
  message 'warning', 'Security Groups found with cidr open to world on ingress.  This should never be true on instance.  Permissible on ELB', security_groups
end

warning '.Resources[] | select(.Type == "AWS::EC2::SecurityGroupIngress")|select(.Properties.CidrIp == "0.0.0.0/0")' do |ingress_rules|
  message 'warning', 'Security Group Standalone Ingress found with cidr open to world. This should never be true on instance.  Permissible on ELB', ingress_rules
end

warning '.Resources[] | select(.Type == "AWS::EC2::SecurityGroup")|select(.Properties.SecurityGroupEgress.CidrIp? == "0.0.0.0/0")' do |security_groups|
  message 'warning', 'Security Groups found with cidr open to world on egress', security_groups
end

warning '.Resources[] | select(.Type == "AWS::EC2::SecurityGroup")|select(.Properties.SecurityGroupEgress|type == "array")|select(.Properties.SecurityGroupEgress[].CidrIp == "0.0.0.0/0")' do |security_groups|
  message 'warning', 'Security Groups found with cidr open to world on egress', security_groups
end

warning '.Resources[] | select(.Type == "AWS::EC2::SecurityGroupEgress")|select(.Properties.CidrIp == "0.0.0.0/0")' do |egress_rules|
  message 'warning', 'Security Group Standalone Egress found with cidr open to world.', egress_rules
end

# BEWARE with escapes \d -> \\\d because of how the escapes get munged from ruby through to shell
warning '.Resources[] | select(.Type == "AWS::EC2::SecurityGroupIngress")|select(.Properties.CidrIp | test("^\\\d{1,3}\\\.\\\d{1,3}\\\.\\\d{1,3}\\\.\\\d{1,3}/(?!32)$") )' do |ingress_rules|
  message 'warning', 'Security Group Standalone Ingress cidr found that is not /32', ingress_rules
end

warning '.Resources[] | select(.Type == "AWS::EC2::SecurityGroup")|select(.Properties.SecurityGroupIngress.CidrIp? | test("^\\\d{1,3}\\\.\\\d{1,3}\\\.\\\d{1,3}\\\.\\\d{1,3}/(?!32)$") )' do |security_groups|
  message 'warning', 'Security Groups found with cidr that is not /32', security_groups
end

warning '.Resources[] | select(.Type == "AWS::EC2::SecurityGroup")|select(.Properties.SecurityGroupIngress|type == "array")|select(.Properties.SecurityGroupIngress[].CidrIp | test("^\\\d{1,3}\\\.\\\d{1,3}\\\.\\\d{1,3}\\\.\\\d{1,3}/(?!32)$"))' do |security_groups|
  message 'warning', 'Security Groups found with cidr that is not /32', security_groups
end

#for inline, this covers it, but with an externalized egress rule... the expression gets real evil
#i guess the ideal would be to do a join of ingress and egress rules with the parent sg
#but it gets real hairy with FnGetAtt for GroupId and all that.... think it best to
#write some imperative code in custom rules to take care of things
# violation '.Resources[]|select(.Type == "AWS::EC2::SecurityGroup")|select(.Properties.SecurityGroupEgress == null or .Properties.SecurityGroupEgress.length? == 0)' do |security_groups|
#   puts "Security Groups found without egress json_rules: #{security_groups}"
# end