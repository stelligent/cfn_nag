# frozen_string_literal: true

require 'git'
require 'fileutils'
require 'cfn-nag/util/git.rb'
require 'docker'

GEM_DIR = '~/.gem'
REPO_DIR = '.'

private

def validate_env
  ENV.fetch('rubygems_api_key')
  ENV.fetch('docker_user')
  ENV.fetch('docker_password')
rescue StandardError => exception
  abort("Error: #{exception}")
end

def build_gem
  system('gem build cfn-nag.gemspec')
  system('gem push cfn-nag-${gem_version}.gem')
end

def publish_docker_image(gem_version)
  image = Docker::Image.build_from_dir('.')
  image.tag('repo' => "#{ENV['docker_org']}/cfn_nag",
            'tag' => gem_version,
            'tag' => 'latest')
  image.push
  image.push(nil, tag: gem_version)
  image.push(nil, tag: 'latest')
end

validate_env
repo_info = repo_current_info(REPO_DIR)
tag_repo(REPO_DIR, repo_info['next_version']) unless repo_info['tagged_commit']
gem_version = (repo_info['tagged_commit'] ? repo_info['version'] : repo_info['next_version'])
build_gem
publish_docker_image(gem_version)
