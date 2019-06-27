# frozen_string_literal: true

docker_run_prefix = "docker run --tty --rm --volume #{Dir.pwd}:/usr/src/app --workdir /usr/src/app cfn-nag-dev:latest"

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
  desc 'Run all rspec tests'
  task :all do
    ensure_local_dev_image
    sh "#{docker_run_prefix} ./scripts/rspec.sh"
  end

  desc 'Run the end-to-end rspec tests'
  task :e2e do
    ensure_local_dev_image
    sh "#{docker_run_prefix} ./scripts/setup_and_run_end_to_end_tests.sh"
  end
end

desc 'Run rubocop'
task :rubocop do
  ensure_local_dev_image
  sh %(#{docker_run_prefix} /bin/bash -c \"rubocop -D\")
end
