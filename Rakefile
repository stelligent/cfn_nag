# frozen_string_literal: true

# Returns a docker run prefix.
# If the command is run inside a running Docker container (determined by the file '/.dockerenv' existing) then it will
# set the mount source as the '$DND_PWD' environment variable.
# If the command is run outside a Docker container then it will just use the regular local '$(pwd)' as the mount source.
def docker_run_prefix
  docker_env = 'docker run --tty --rm --mount source=$DND_PWD,target=/usr/src/app,type=bind ' \
    '--workdir /usr/src/app cfn-nag-dev:latest'
  local_env = "docker run --tty --rm --mount source=#{Dir.pwd},target=/usr/src/app,type=bind " \
    '--workdir /usr/src/app cfn-nag-dev:latest'
  prefix = File.file?('/.dockerenv') ? docker_env : local_env
  prefix
end

def ensure_local_dev_image
  puts 'Checking for cfn-nag-dev Docker image...'
  image = `docker images -q cfn-nag-dev:latest`

  if image.empty?
    puts 'cfn-nag-dev image is missing. Building it first...'
    Rake::Task['build_docker_dev'].invoke
  else
    puts 'cfn-nag-dev image exists, proceeding.'
  end
end

#### Tasks ################

desc 'run rspec locally (do bundle exec rake spec)'
task :spec do
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new do |rake_task|
    rake_task.rspec_opts = '--tag ~end_to_end -b'
  end
end

desc 'Build the local Docker image for development/testing'
task :build_docker_dev do
  sh 'docker build --file Dockerfile-dev --rm --tag cfn-nag-dev .'
end

namespace 'test' do
  desc 'Run all rspec tests (via docker)'
  task :all do
    ensure_local_dev_image
    sh %(#{docker_run_prefix} /bin/sh scripts/rspec.sh)
  end

  desc 'Run the end-to-end rspec tests (via docker)'
  task :e2e do
    ensure_local_dev_image
    sh %(#{docker_run_prefix} /bin/sh scripts/setup_and_run_end_to_end_tests.sh)
  end
end

desc 'Run rubocop'
task :rubocop do
  ensure_local_dev_image
  sh %(#{docker_run_prefix} /bin/sh -c \"rubocop -D\")
end
