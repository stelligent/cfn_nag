Feature:
  As a Dev(Sec)Ops engineer or security auditor
  I would like to look for bad port range specifications in Cloudformation JSON template
  So that I can have very fast feedback about potential security problems

  Scenario: An inline ingress rule in a security group has a port range defined
    Given a Cloudformation template that creates a security group with an inline ingress rule with a port range
    When analyzing the template
    Then a warning is flagged

  Scenario: A standalone ingress rule has a port range defined
    Given a Cloudformation template that creates a standalone ingress rule with a port range
    When analyzing the template
    Then a warning is flagged

  Scenario: An inline egress rule in a security group has a port range defined
    Given a Cloudformation template that creates a security group with an inline egress rule with a port range
    When analyzing the template
    Then a warning is flagged

  Scenario: A standalone egress rule has a port range defined
    Given a Cloudformation template that creates a standalone egress rule with a port range
    When analyzing the template
    Then a warning is flagged