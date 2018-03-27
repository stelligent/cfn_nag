require 'rake'

Gem::Specification.new do |s|
  s.name          = 'cfn-nag'
  s.license       = 'MIT'
  s.version       = ENV['GEM_VERSION'] || '0.0.0'
  s.bindir        = 'bin'
  s.executables   = %w[cfn_nag cfn_nag_rules cfn_nag_scan]
  s.authors       = ['Eric Kascic']
  s.summary       = 'cfn-nag'
  s.description   = 'Auditing tool for CloudFormation templates'
  s.homepage      = 'https://github.com/stelligent/cfn_nag'
  s.files         = FileList['lib/**/*.rb']

  s.require_paths << 'lib'

  s.required_ruby_version = '~> 2.2'

  s.add_development_dependency('rspec', '~> 3.4')
  s.add_development_dependency('simplecov', '~> 0.11')

  s.add_runtime_dependency('cfn-model', '0.1.22')
  s.add_runtime_dependency('jmespath', '1.3.1')
  s.add_runtime_dependency('logging', '2.2.2')
  s.add_runtime_dependency('netaddr', '1.5.1')
  s.add_runtime_dependency('trollop', '2.1.2')
end
