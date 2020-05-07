require 'cfn-nag/iam_complexity_metric/spcm'
require 'cfn-model/model/statement'

describe SPCM do
  describe '#metric' do
    context 'policy and a role' do
      it 'computes the spcm metrics for the policy and map' do
        cloudformation_string = <<END
Parameters:
  Action:
    Type: String
  Resource:
    Type: String

Resources:
  GenericGroup:
    Type: AWS::IAM::Group
    Properties: 
      GroupName: GenericGroup

  Policy:
    Type: AWS::IAM::Policy 
    Properties:
      PolicyName: WildcardResourcePolicy
      PolicyDocument:
        Version: "2012-10-17"
        Statement:
          -
            Effect: Allow
            Action: "iam:PassRole"
            Resource: "*"
      Groups:
        - !Ref GenericGroup

  HelperRole:
    Type: AWS::IAM::Role
    Properties:
      AssumeRolePolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal: 
              Service: lambda.amazonaws.com
            Action: sts:AssumeRole
            Path: /
      Policies:
        - PolicyName: awstestingLambdaExecutePolicies
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action:
                  - tag:TagResources
                  - tag:UntagResources
                  - !Sub elasticloadbalancing:${Action}
                  - logs:CreateLogGroup
                  - logs:CreateLogStream
                  - logs:PutLogEvents
                  - s3:PutBucketPolicy
                Resource: !Ref Resource
        - PolicyName: fred
          PolicyDocument:
            Version: '2012-10-17'
            Statement:
              - Effect: Allow
                Action: '*'
                Resource: !Ref Resource
END
        parameter_values_string = <<END
{
  "Parameters": {
    "Action" : "*",
    "Resource": "arn:aws:s3:::NAME-OF-YOU-BUCKET"
  }
}
END
        spcm = SPCM.new
        actual_policy_documents = spcm.metric(
          cloudformation_string: cloudformation_string,
          parameter_values_string: parameter_values_string
        )

        expected_policy_documents = {
          'AWS::IAM::Policy' => {
            'Policy' => 1
          },
          'AWS::IAM::Role' => {
            'HelperRole' => {
              'awstestingLambdaExecutePolicies' => 7,
              'fred' => 1
            }
          }
        }
        expect(actual_policy_documents).to eq expected_policy_documents
      end
    end
  end
end