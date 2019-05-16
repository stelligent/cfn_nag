#!/bin/bash -l

set -e

# Function for downloading/scanning templates to check for exceptions
download_and_scan_templates () {
  mkdir spec/aws_sample_templates || true
  pushd spec/aws_sample_templates
  curl -O https://s3-eu-west-1.amazonaws.com/cloudformation-examples-eu-west-1/AWSCloudFormation-samples.zip
  rm -f *.template
  rm -rf aws-cloudformation-templates
  unzip AWSCloudFormation-samples.zip
  git clone https://github.com/awslabs/aws-cloudformation-templates.git
  popd
  # Macros/SAM cause exceptions in cfn-model, removing these two directories
  # allow us to successfully lint everything else.
  rm -rf spec/aws_sample_templates/aws-cloudformation-templates/aws/services/CloudFormation/MacrosExamples
  rm -rf spec/aws_sample_templates/aws-cloudformation-templates/community/services/Lambda/SAM
  echo -e "\n"

  # Run cfn_nag_scan on a directory of templates, scan stderr for an uppercase
  # 'Error' which incidates an exception was thrown. For whatever reason,
  # not every ruby exception/stacktrace contains the word 'exception'.
  echo -e "Linting sample templates..\n"
  # set +e because cfn_nag_scan failures are OK; Exceptions are not
  set +e
  cfn_nag_scan -i ./spec/aws_sample_templates 2>&1 >/dev/null | grep -A 25 Error

  # Since grep exits with a status code of 0 when it matches a pattern, if
  # the above command exits 0 then that means cfn_nag_scan threw an exception
  if [ $? -eq 0 ]; then
    echo -e "\nException found in cfn_nag_scan, exiting..\n"
    exit 1
  else
    echo -e "\ncfn_nag_scan did not throw any exceptions, yay!"
  fi
}

# Test for RVM and create a new gemset for local testing,
# irrelevant for CircleCI testing, this is just to squelch errors in the
# CircleCI build
if [ -x "$(which rvm)" ]; then
  rvm use 2.5.5
  rvm --force gemset delete cfn_end_to_end
  rvm gemset use cfn_end_to_end --create
else
  echo 'RVM is not installed, consider installing to run e2e tests locally.'
fi

# Build and install gem locally, using version 0.0.01
./scripts/deploy_local.sh

# Install the two gems required to run end-to-end tests
gem install rspec -v '~> 3.4' --no-document
gem install simplecov -v '~> 0.11' --no-document

# Execute end-to-end tests
rspec -t end_to_end

# Call function to download & scan templates, exit 1 if an exception is thrown
download_and_scan_templates
