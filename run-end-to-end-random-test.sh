#!/bin/bash -l

rvm use 2.2.1
rvm --force gemset delete cfn_nag
rvm gemset use cfn_nag --create

./deploy_local.sh

for template in $(ls spec/aws_sample_templates/*.template)
do
  echo ${template}
  cfn_nag --input-json ${template};
done
