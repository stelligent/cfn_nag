#!/bin/bash -l

rvm use 2.2.1
rvm --force gemset delete cfn_nag
rvm gemset use cfn_nag --create

./deploy_local.sh

mkdir spec/aws_sample_templates || true
pushd spec/aws_sample_templates
wget https://s3-eu-west-1.amazonaws.com/cloudformation-examples-eu-west-1/AWSCloudFormation-samples.zip
unzip AWSCloudFormation-samples.zip
popd

for template in $(ls spec/aws_sample_templates/*.template)
do
  echo ${template}
  cfn_nag --input-json ${template};
done
