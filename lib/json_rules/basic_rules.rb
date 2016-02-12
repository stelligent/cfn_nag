fatal_assertion '.Resources|length > 0' do
  message('fatal', 'Must have at least 1 resource')
end

fatal_violation '.Resources[] | select(.Type == "AWS::EC2::SecurityGroup" and .Properties == null)' do |security_groups|
  message('fatal', 'Security Groups must have Properties', security_groups)
end

fatal_violation '.Resources[] | select(.Type == "AWS::EC2::SecurityGroupIngress" and .Properties == null)' do |ingress|
  message('fatal', 'Security Group Ingress must have Properties', ingress)
end

fatal_violation '.Resources[] | select(.Type == "AWS::EC2::SecurityGroupEgress" and .Properties == null)' do |egress|
  message('fatal', 'Security Group Egress must have Properties', egress)
end


fatal_violation '.Resources[] | select(.Type == "AWS::EC2::SecurityGroupEgress" and .Properties == null)' do |egress|
  message('fatal', 'Security Group Egress must have Properties', egress)
end

fatal_violation '((([..|.Ref?]|map(select(. != null)) +  [..|."Fn::GetAtt"?[0]]|map(select(. != null)))) - ([.Resources|keys]|flatten))|if length==0 then false else . end' do |danglers|
  message('fatal', 'All Ref and Fn::GetAtt must reference existing logical resource ids', danglers)
end
