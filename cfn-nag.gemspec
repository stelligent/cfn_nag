require 'rake'

Gem::Specification.new do |s|
  s.name          = 'cfn-nag'
  s.version       = '0.0.0'
  s.bindir        = 'bin'
  s.executables   = %w(cfn_nag cfn_nag_rules)
  s.authors       = %w(someguy)
  s.summary       = 'cfn-nag'
  s.description   = 'Auditing tool for Cloudformation templates'
  s.files         = FileList[ 'lib/**/*.rb' ]

  s.require_paths << 'lib'

  s.required_ruby_version = '~> 2.2'
  
  s.add_runtime_dependency('logging', '2.0.0')
  s.add_runtime_dependency('trollop', '2.1.2')
end