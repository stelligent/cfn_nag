require_relative '../rule'

class SecurityGroupMissingEgressRule
  include Rule

  def audit(cfn_model)
    violation_count = 0

    cfn_model.security_groups.each do |security_group|
      if security_group.egress_rules.size == 0
        message 'violation', 'Missing egress rule means all traffic is allowed outbound.  Make this explicit if it is desired configuration', security_group
        violation_count += 1
      end
    end
    violation_count
  end
end