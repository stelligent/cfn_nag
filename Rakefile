# frozen_string_literal: true

docker_run_prefix = "docker run --tty --rm --volume #{Dir.pwd}:/usr/src/app --workdir /usr/src/app cfn-nag-dev:latest"

def dev_image_missing?
  image = `docker images -q cfn-nag-dev:latest`

  if image.empty?
    puts 'The local dev image is missing. You must first run `rake build_docker_dev`'
    true
  else
    false
  end
end

desc 'Build the local Docker iamge for development/testing'
task :build_docker_dev do
  sh 'docker build --file Dockerfile-dev --rm --tag cfn-nag-dev .'
end

namespace 'test' do
  desc 'Run all rspec tests'
  task :all do
    sh "#{docker_run_prefix} ./scripts/rspec.sh" unless dev_image_missing?
  end

  desc 'Run the end-to-end rspec tests'
  task :e2e do
    sh "#{docker_run_prefix} ./scripts/setup_and_run_end_to_end_tests.sh" unless dev_image_missing?
  end
end

desc 'Run rubocop'
task :rubocop do
  sh %(#{docker_run_prefix} /bin/bash -c \"rubocop -D\") unless dev_image_missing?
end
