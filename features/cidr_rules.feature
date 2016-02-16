Feature:
  As a Dev(Sec)Ops engineer or security auditor
  I would like to look for bad CIDR range specifications in Cloudformation JSON template
  So that I can have very fast feedback about potential security problems

  Scenario: An inline ingress rule in a security group has a CIDR range open to the world (0.0.0.0/0)
    Given a Cloudformation template that creates a security group with an inline ingress rule with a CIDR range open to the world (0.0.0.0/0)
    When analyzing the template
    Then a warning is flagged

  Scenario: A standalone ingress rule has a CIDR range open to the world (0.0.0.0/0)
    Given a Cloudformation template that creates a standalone ingress rule with a CIDR range open to the world (0.0.0.0/0)
    When analyzing the template
    Then a warning is flagged

  Scenario: An inline ingress rule in a security group has a CIDR range that is not /32
    Given a Cloudformation template that creates a security group with an inline ingress rule with a CIDR range that is not /32)
    When analyzing the template
    Then a warning is flagged

  Scenario: A standalone ingress rule has a CIDR range that is not /32
    Given a Cloudformation template that creates a standalone ingress rule with a CIDR range that is not /32
    When analyzing the template
    Then a warning is flagged

  Scenario: An inline egress rule in a security group has a CIDR range open to the world (0.0.0.0/0)
    Given a Cloudformation template that creates a security group with an inline egress rule with a CIDR range open to the world (0.0.0.0/0)
    When analyzing the template
    Then a warning is flagged

  Scenario: A standalone egress rule has a CIDR range open to the world (0.0.0.0/0)
    Given a Cloudformation template that creates a standalone egress rule with a CIDR range open to the world (0.0.0.0/0)
    When analyzing the template
    Then a warning is flagged

  Scenario: An inline egress rule in a security group has a CIDR range that is not /32
    Given a Cloudformation template that creates a security group with an inline egress rule with a CIDR range that is not /32)
    When analyzing the template
    Then a warning is flagged

  Scenario: A standalone egress rule has a CIDR range that is not /32
    Given a Cloudformation template that creates a standalone egress rule with a CIDR range that is not /32
    When analyzing the template
    Then a warning is flagged

  Scenario: A security group with no egress rules at all
    Given a Cloudformation template that creates a security group with no explicit egress rules
    When analyzing the template
    Then a violation is flagged because this means everything is open outbound