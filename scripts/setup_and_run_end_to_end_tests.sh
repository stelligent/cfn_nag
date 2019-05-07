#!/bin/bash -l

# Create a new gemset for local testing, irrelevant for CircleCI testing
rvm use 2.5.5
rvm --force gemset delete cfn_end_to_end
rvm gemset use cfn_end_to_end --create

# Build and install gem locally, using version 0.0.01
./scripts/deploy_local.sh

# Install the two gems required to run end-to-end tests
gem install rspec -v '~> 3.4' --no-document
gem install simplecov -v '~> 0.11' --no-document

# Pull down sample templates, etc
mkdir spec/aws_sample_templates || true
pushd spec/aws_sample_templates
curl -O https://s3-eu-west-1.amazonaws.com/cloudformation-examples-eu-west-1/AWSCloudFormation-samples.zip
rm *.template
rm -rf aws-cloudformation-templates
unzip AWSCloudFormation-samples.zip
git clone https://github.com/awslabs/aws-cloudformation-templates.git
popd

# Execute end-to-end tests
rspec -t end_to_end
