# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name          = 'cfn-nag'
  s.license       = 'MIT'
  s.version       = ENV['GEM_VERSION'] || '0.0.0'
  s.bindir        = 'bin'
  s.executables   = %w[cfn_nag cfn_nag_rules cfn_nag_scan spcm_scan]
  s.authors       = ['Eric Kascic']
  s.summary       = 'cfn-nag'
  s.description   = 'Auditing tool for CloudFormation templates'
  s.homepage      = 'https://github.com/stelligent/cfn_nag'
  s.files         = Dir.glob('lib/**/*.rb')

  s.require_paths << 'lib'

  s.required_ruby_version = '>= 2.2'

  s.add_development_dependency('rake')
  s.add_development_dependency('rspec', '~> 3.4')
  s.add_development_dependency('rubocop')
  s.add_development_dependency('simplecov', '~> 0.11')

  # don't relax this, i don't want different versions of cfn-model being installed after the fact
  # versus what we used to run tests in cfn-nag before publishing cfn-nag
  # they are coupled and we are doing a good bit of experimenting in cfn-model
  # i might consider collapsing them again....
  s.add_runtime_dependency('cfn-model', '0.5.4')
  s.add_runtime_dependency('logging', '~> 2.2.2')
  s.add_runtime_dependency('netaddr', '~> 2.0.4')
  s.add_runtime_dependency('optimist', '~> 3.0.0')

  # this is NOT an invitation to make requests to AWS...
  # this dependency is here only to optionally retrieve rules from s3
  # cfn_nag is a static analysis tool that must be workable with NO network connectivity
  s.add_runtime_dependency('aws-sdk-s3', '~> 1.76')
  s.add_runtime_dependency('lightly', '~> 0.3.2')

  # WARNING: don't add any gems with poisonous GPL licenses
end
