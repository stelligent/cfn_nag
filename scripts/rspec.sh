#!/bin/bash -l

set -e

# Build and install gem locally, using version 0.0.01
/bin/sh scripts/deploy_local.sh

# Install the two gems required to run end-to-end tests
echo "installing rspec and simplecov for testing"
PATH=$PATH:/usr/local/bundle/bin
gem install rspec --explain -v '~> 3.4' --no-document
gem install rspec -v '~> 3.4' --no-document
gem install simplecov -v '~> 0.11' --no-document

echo "begin all rspec tests..."
# Execute end-to-end tests
rspec