warning '.Resources[] | select(.Type == "AWS::EC2::SecurityGroup" and (.Properties.SecurityGroupIngress|type == "object"))|select(.Properties.SecurityGroupIngress.ToPort != .Properties.SecurityGroupIngress.FromPort)' do |security_groups|
  message 'warning', 'Security Groups found with port range instead of just a single port', security_groups
end

warning '.Resources[] | select(.Type == "AWS::EC2::SecurityGroup" and (.Properties.SecurityGroupIngress|type == "array"))|select(.Properties.SecurityGroupIngress[].ToPort != .Properties.SecurityGroupIngress[].FromPort)' do |security_groups|
  message 'warning', 'Security Groups found with cidr open to world on ingress.  This should never be true on instance.  Permissible on ELB', security_groups
end

warning '.Resources[] | select(.Type == "AWS::EC2::SecurityGroup" and (.Properties.SecurityGroupEgress|type == "object"))|select(.Properties.SecurityGroupEgress.ToPort != .Properties.SecurityGroupEgress.FromPort)' do |security_groups|
  message 'warning', 'Security Groups found with port range instead of just a single port', security_groups
end

warning '.Resources[] | select(.Type == "AWS::EC2::SecurityGroup" and (.Properties.SecurityGroupEgress|type == "array"))|select(.Properties.SecurityGroupEgress[].ToPort != .Properties.SecurityGroupEgress[].FromPort)' do |security_groups|
  message 'warning', 'Security Groups found with port range instead of just a single port', security_groups
end

warning '.Resources[] | select(.Type == "AWS::EC2::SecurityGroupIngress")|select(.Properties.ToPort != .Properties.FromPort)' do |ingress_rules|
  message 'warning', 'Security Groups found with port range instead of just a single port', ingress_rules
end

warning '.Resources[] | select(.Type == "AWS::EC2::SecurityGroupEgress")|select(.Properties.ToPort != .Properties.FromPort)' do |egress_rules|
  message 'warning', 'Security Groups found with port range instead of just a single port', egress_rules
end