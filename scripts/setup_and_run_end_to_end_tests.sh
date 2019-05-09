#!/bin/bash -l

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
