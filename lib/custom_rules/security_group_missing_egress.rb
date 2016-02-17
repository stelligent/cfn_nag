require_relative '../rule'

class SecurityGroupMissingEgressRule
  include Rule

  def audit(cfn_model)
    violation_count = 0

    logical_resource_ids = []
    violating_security_groups = []
    cfn_model.security_groups.each do |security_group|
      if security_group.egress_rules.size == 0
        logical_resource_ids << security_group.logical_resource_id
        violating_security_groups << security_group
        violation_count += 1
      end
    end

    if violation_count > 0
      message message_type: 'violation',
              message: 'Missing egress rule means all traffic is allowed outbound.  Make this explicit if it is desired configuration',
              logical_resource_ids: logical_resource_ids
    end
    violation_count
  end
end