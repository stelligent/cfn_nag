# frozen_string_literal: true

require 'git'

def repo_current_info(location)
  git = open_repo(location)

  current_tag = git.describe
  current_version = current_tag.gsub(/v?([0-9.]+).*/, '\1')
  major, minor, patch = current_version.split('.')
  new_version = (current_tag.include?('-') ? "#{major}.#{minor}.#{patch.to_i + 1}" : nil)

  { 'tag' => current_tag,
    'version' => current_version,
    'major' => major,
    'minor' => minor,
    'patch' => patch,
    'new_version' => new_version }
rescue Git::GitExecuteError
  { 'tag' => nil,
    'version' => nil,
    'major' => nil,
    'minor' => nil,
    'patch' => nil,
    'new_version' => '0.0.1' }
end

private

def open_repo(location)
  git = Git.open(location)
  git.config('user.name', 'build') if git.config('user.name').empty?
  git.config('user.email', 'build@build.com') if git.config('user.email').empty?
  git
rescue StandardError => git_error
  raise "Git error for #{location}: #{git_error}"
end

# åputs open_repo('/tmp/dir1')
# puts repo_current_info('/tmp/repo1')
# puts repo_current_info('~/repos/cfn_nag')
