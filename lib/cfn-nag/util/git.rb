# frozen_string_literal: true

require 'git'

def repo_current_info(_location)
  git = open_repo(location)

  current_tag = git.describe
  current_version = current_tag.gsub(/v?([0-9.]+).*/, '\1')
  major, minor, patch = current_version.split('.')

  { 'tag' => current_tag,
    'tagged_commit' => (current_tag.include?('-') ? 1 : 0),
    'version' => current_version,
    'major' => major,
    'minor' => minor,
    'patch' => patch }
end

private

def open_repo(location)
  git = Git.open(location)
  git.config('user.name', 'build') if git.config('user.name').empty?
  git.config('user.email', 'build@build.com') if git.config('user.email').empty?
  git
rescue StandardError => git_error
  abort("Git error for #{location}: #{git_error}")
end
