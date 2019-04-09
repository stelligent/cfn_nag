<img src="logo.png?raw=true" width="150">
<br/>

# Background
The cfn-nag tool looks for patterns in CloudFormation templates that may indicate insecure infrastructure.
Roughly speaking it will look for:

* IAM rules that are too permissive (wildcards)
* Security group rules that are too permissive (wildcards)
* Access logs that aren't enabled
* Encryption that isn't enabled

For more background on the tool, please see:  

[Finding Security Problems Early in the Development Process of a CloudFormation Template with "cfn-nag"](https://stelligent.com/2016/04/07/finding-security-problems-early-in-the-development-process-of-a-cloudformation-template-with-cfn-nag/)

# Installation
Presuming Ruby 2.4.x or 2.5.x is installed, installation is just a matter of:

    gem install cfn-nag

# Pipeline
To run `cfn_nag` as an action in CodePipeline, you can deploy via the [AWS Serverless Application Repository](https://serverlessrepo.aws.amazon.com/applications/arn:aws:serverlessrepo:us-east-1:923120264911:applications~cfn-nag-pipeline).

# Usage
Pretty simple to execute:

    cfn_nag_scan --input-path <path to cloudformation json>

The path can be a directory or a particular template.  If it is a directory, all \*.json, \*.template, \*.yml and \*.yaml files underneath
there recursively will be processed.

The default output format is free-form text, but json output can be selected with the `--output-format json` flag.    

Optionally, a `--debug` flag will dump information about the internals of rule loading.

Run with `--help` for a full listing of supported switches.

To see a list of all the rules the cfn-nag currently supports, there is a command-line utility that will dump them to stdout:

    cfn_nag_rules

## Results
* The results are dumped to stdout
* A failing violation will return a non-zero exit code.
* A warning will return a zero/success exit code.
* A fatal violation stops analysis (per file) because the template is malformed in some severe way

## Rule Suppression

In the event that there is a rule that you want to suppress, a `cfn_nag` `Metadata` key can be added to the affected resource to tell cfn_nag to not raise a failure or warning for that rule.

For example, if you are setting up a public-facing ELB that's open to inbound connections from the internet with resources like the following:

`public_alb.yaml`
```yaml
# Partial template
PublicAlbSecurityGroup:
  Properties:
    GroupDescription: 'Security group for a public Application Load Balancer'
    VpcId:
      Ref: vpc
  Type: AWS::EC2::SecurityGroup
PublicAlbSecurityGroupHttpIngress:
  Properties:
    CidrIp: 0.0.0.0/0
    FromPort: 80
    GroupId:
      Ref: PublicAlbSecurityGroup
    IpProtocol: tcp
    ToPort: 80
  Type: AWS::EC2::SecurityGroupIngress
```

cfn_nag will raise warnings like the following:

```
$ cfn_nag_scan -i public_alb.yaml
------------------------------------------------------------
public_alb.yaml
------------------------------------------------------------------------------------------------------------------------
| WARN W9
|
| Resources: ["PublicAlbSecurityGroup"]
|
| Security Groups found with ingress cidr that is not /32
------------------------------------------------------------
| WARN W2
|
| Resources: ["PublicAlbSecurityGroup"]
|
| Security Groups found with cidr open to world on ingress.  This should never be true on instance.  Permissible on ELB

Failures count: 0
Warnings count: 2
```

By adding the metadata, these warnings can be suppressed:

`public_alb_with_suppression.yaml`
```yaml
# Partial template
PublicAlbSecurityGroup:
  Properties:
    GroupDescription: 'Security group for a public Application Load Balancer'
    VpcId:
      Ref: vpc
  Type: AWS::EC2::SecurityGroup
  Metadata:
    cfn_nag:
      rules_to_suppress:
        - id: W9
          reason: "This is a public facing ELB and ingress from the internet should be permitted."
        - id: W2
          reason: "This is a public facing ELB and ingress from the internet should be permitted."
PublicAlbSecurityGroupHttpIngress:
  Properties:
    CidrIp: 0.0.0.0/0
    FromPort: 80
    GroupId:
      Ref: PublicAlbSecurityGroup
    IpProtocol: tcp
    ToPort: 80
  Type: AWS::EC2::SecurityGroupIngress
```

```
$ cfn_nag_scan -i public_alb_with_suppression.yaml
------------------------------------------------------------
public_alb_with_supression.yaml
------------------------------------------------------------
Failures count: 0
Warnings count: 0
```

# Setting Template Parameter Values
CloudFormation Template Parameters can present a problem for static analysis as the values are specified at the point
of deployment.  In other words, the values aren't available when the static analysis is done - static analysis
can only look at the "code" that is in front of it.  Therefore a security group ingress rule of 0.0.0.0/0 won't
be flagged if the cidr is parameterized and the 0.0.0.0/0 is passed in at deploy time.

To allow for checking parameter values, a user can specify the parameter values in a JSON file passed on the command line
to both `cfn_nag` and `cfn_nag_scan` with the `--parameter-values-path=<filename/uri>` flag.  

The format of the JSON is a single key "Parameters" whose value is a dictionary with each key/value pair mapping to
the Parameters like such:

```json
{
  "Parameters": {
    "Cidr": "0.0.0.0/0"
  }
}
```

will fill in "0.0.0.0/0" to the following Parameter:

```yaml
Parameters:
  Cidr:
    Type: String
```

_BEWARE_ that if there are extra parameters in the JSON they are quietly ignored (to allow `cfn_nag_scan` to apply
the same JSON across all the templates)

If the JSON is malformed or doesn't meet the above specification, then parsing will fail with FATAL violation.

# Development

## New Rules
To author new rules for your own use and/or community contribution, see [migration.md](migration.md) for details.
