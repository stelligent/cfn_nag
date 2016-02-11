warning '.Resources[] | select(.Type == "AWS::EC2::SecurityGroup")|select(.Properties.SecurityGroupIngress.CidrIp? == "0.0.0.0/0")' do |security_groups|
  puts "WARNING: Security Groups found with open cidr on ingress: #{security_groups}"
end

warning '.Resources[] | select(.Type == "AWS::EC2::SecurityGroup")|select(.Properties.SecurityGroupIngress|type == "array")|select(.Properties.SecurityGroupIngress[].CidrIp == "0.0.0.0/0")' do |security_groups|
  puts "WARNING: Security Groups found with open cidr on ingress: #{security_groups}"
end

warning '.Resources[] | select(.Type == "AWS::EC2::SecurityGroupIngress")|select(.Properties.CidrIp == "0.0.0.0/0")' do |ingress_rules|
  puts "WARNING: Security Group Standalone Ingress json_rules found with open cidr: #{ingress_rules}"
end

warning '.Resources[] | select(.Type == "AWS::EC2::SecurityGroup")|select(.Properties.SecurityGroupEgress.CidrIp? == "0.0.0.0/0")' do |security_groups|
  puts "WARNING: Security Groups found with open cidr on egress: #{security_groups}"
end

warning '.Resources[] | select(.Type == "AWS::EC2::SecurityGroup")|select(.Properties.SecurityGroupEgress|type == "array")|select(.Properties.SecurityGroupEgress[].CidrIp == "0.0.0.0/0")' do |security_groups|
  puts "WARNING: Security Groups found with open cidr on ingress: #{security_groups}"
end

warning '.Resources[] | select(.Type == "AWS::EC2::SecurityGroupEgress")|select(.Properties.CidrIp == "0.0.0.0/0")' do |egress_rules|
  puts "WARNING: Security Group Standalone Egress json_rules found with open cidr: #{egress_rules}"
end


#for inline, this covers it, but with an externalized egress rule... the expression gets real evil
#i guess the ideal would be to do a join of ingress and egress rules with the parent sg
#but it gets real hairy with FnGetAtt for GroupId and all that.... think it best to
#write some imperative code in custom rules to take care of things
# violation '.Resources[]|select(.Type == "AWS::EC2::SecurityGroup")|select(.Properties.SecurityGroupEgress == null or .Properties.SecurityGroupEgress.length? == 0)' do |security_groups|
#   puts "Security Groups found without egress json_rules: #{security_groups}"
# end