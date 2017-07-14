#!/bin/bash -l

rvm use 2.2.1
rvm --force gemset delete cfn_nag
rvm gemset use cfn_nag --create

./deploy_local.sh

mkdir spec/aws_sample_templates || true
pushd spec/aws_sample_templates
wget https://s3-eu-west-1.amazonaws.com/cloudformation-examples-eu-west-1/AWSCloudFormation-samples.zip
rm *.template
rm -rf aws-cloudformation-templates
unzip AWSCloudFormation-samples.zip
git clone https://github.com/awslabs/aws-cloudformation-templates.git
popd

cfn_nag_scan --input-path spec/aws_sample_templates \
             --output-format txt
