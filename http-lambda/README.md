## Pre-requisites

0. Install node.js
   * For more information see: https://nodejs.org/en/

1. Install serverless
   * For more information see: https://serverless.com/framework/docs/getting-started/

2. Install Maven (Java)
   * For more information see: https://maven.apache.org/install.html

3. Configure credentials for an AWS account in the environment
   * The credentials will need permission to create an S3 bucket, lambda functions, and an IAM role for the functions (at least)
 
## Build the cfn-nag lambda

`mvn clean install`

## Deploy the cfn-nag lambda

`serverless deploy`

This will output your lambda invocation URL.

## Use the Lambda

`curl --data-binary @/path/to/cloudformation.template.or.yml <lambda-url>`
