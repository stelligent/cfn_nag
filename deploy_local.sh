#!/bin/bash

gem uninstall cfn-nag -x
gem build cfn-nag.gemspec
gem install cfn-nag-0.0.0.gem --no-ri --no-rdoc
