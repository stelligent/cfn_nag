Feature:
  As a Cloudformation developer
  I would like to know when templates are malformed quickly
  So that I can save time during developemnt and not have to wait for cfn service to tell me


Scenario: Resources must have at least 1 resource
  Given a Cloudformation template with zero resources
   When analyzing the template
   Then a fatal violation is flagged that stops analysis

Scenario: Resources with mandatory fields must contain Properties field
  Given a Cloudformation template
   When analyzing the template
   Then a fatal violation is flagged that stops analysis when these resources have no Properties:
    | AWS::IAM::Role                 |
    | AWS::IAM::Policy               |
    | AWS::IAM::ManagedPolicy        |
    | AWS::IAM::UserToGroupAddition  |
    | AWS::EC2::SecurityGroup        |
    | AWS::EC2::SecurityGroupIngress |
    | AWS::EC2::SecurityGroupEgress  |

Scenario: All resource and attribute references must point to declared resources
  Given a Cloudformation template
   When analyzing the template
   Then a fatal violation is flagged that stops analysis if Ref or Fn::GetAtt refers to an undeclared resource
