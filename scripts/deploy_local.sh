#!/bin/bash

echo "Installing cfn_nag from local source"
gem uninstall cfn-nag -x
brew gem uninstall cfn-nag
gem build cfn-nag.gemspec
gem install cfn-nag-0.0.0.gem --no-document
