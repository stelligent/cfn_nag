# frozen_string_literal: true

require 'git'

def repo_current_info(location)
  git = open_repo(location)

  current_tag = git.describe
  current_version = current_tag.gsub(/v?([0-9.]+).*/, '\1')
  major, minor, patch = current_version.split('.')
  tagged_commit = !current_tag.include?('-')
  next_version = "#{major}.#{minor}.#{patch.to_i + 1}"

  { 'tag' => current_tag,
    'version' => current_version,
    'next_version' => next_version,
    'tagged_commit' => tagged_commit }
rescue Git::GitExecuteError
  { 'tag' => nil,
    'version' => nil,
    'next_version' => '0.0.1',
    'tagged_commit' => false }
end

def tag_repo(repo_dir, tag_name)
  git = open_repo(repo_dir)
  git.add_tag(tag_name, message: tag_name)
  begin
    git.push
  rescue StandardError => git_error
    raise "Git error pushing tag: #{git_error} "
  end
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
