#!/usr/bin/ruby

require 'logger'
require 'fileutils'
require 'open3'

major_version = 0
minor_version = 6

# Use this for shelling out
def run(cmd:, input: nil)
  Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
    stdin.write(input) unless input.nil?
    stdin.close_write unless input.nil?
    status = wait_thr.value.exitstatus
    if status != 0
      puts(stderr.read)
      puts("#{cmd} returned #{status}")
      exit status
    end
    return stdout.read, stderr.read
  end
end

# Ensure we have all environment variables we need set
failed = 0
["rubygems_api_key", "docker_user", "docker_password", "docker_org"].each do |v|
  if ENV[v] == nil
    puts "#{v} must be set in the environment"
    failed = 1
  end
end
exit 1 if failed > 0

# Setup a logger
logger = Logger.new(STDOUT)
if ARGV.include? '-d'
  logger.level = Logger::DEBUG
else
  logger.level = Logger::INFO
end

# Set global git config user and email
cmd='git config --global user.email "build@build.com" && '\
    'git config --global user.name "build"'
logger.debug("Running #{cmd}")
run(cmd: cmd)

# Create ~/.gem/credentials and populate it with secret from env
gem_dir = File.join(Dir.home, ".gem")
Dir.mkdir(gem_dir) unless File.exists?(gem_dir)
creds_file = File.join(Dir.home, ".gem", "credentials")
File.write(creds_file, ":rubygems_api_key: #{ENV['rubygems_api_key']}\n")
FileUtils.chmod(0600, creds_file)

# Find the largest patch version of the minor version
# I.e. if minor version is 4 and there is a v0.4.0 - v0.4.82, then return 82
cmd = "git tag -l v#{major_version}.#{minor_version}.*"
logger.debug("Running #{cmd}")
tags, stderr = run(cmd: cmd)
patch_version = tags.lines.map { |tag| tag.sub(/v#{major_version}.#{minor_version}./, "").chomp.to_i }.max
previous_version = ""
new_version = ""
if patch_version == nil
  patch_version = 0
  # New version without the prefix "v"
  new_version = "#{major_version}.#{minor_version}.#{patch_version}"
else
  previous_version = "#{major_version}.#{minor_version}.#{patch_version}"
  patch_version += 1
  # New version without the prefix "v"
  new_version = "#{major_version}.#{minor_version}.#{patch_version}"
end
logger.debug "patch_version = \"#{patch_version}\""

# Get the most recent tag
cmd = 'git describe --abbrev=0 || echo ""'
logger.debug("Running #{cmd}")
stdout, stderr = run(cmd: cmd)
last_tag = stdout.chomp

logger.debug("last_tag is \"#{last_tag}\"")
logger.debug("previous_version is \"#{previous_version}\"")
logger.debug("new_version is \"#{new_version}\"")

# Write the version in the gemspec file and make a backup
cmd = "sed -i.bak \"s/0\.0\.0/#{new_version}/g\" cfn-nag.gemspec"
logger.debug("Running #{cmd}")
run(cmd: cmd)


# On circle ci - head is ambiguous for reasons that I don't grok
# We haven't made the new tag and we can't if we are going to annotate
cmd = "git rev-parse HEAD"
head, stderr = run(cmd: cmd)
logger.debug("head = #{head}")

issue_prefix='^#'
logger.info("Remember! You need to start your commit messages with #x, where x is the issue number your commit resolves.")

if previous_version == ""
  log_rev_range = "#{last_tag}..#{head}"
else
  log_rev_range = "v#{previous_version}..#{head}"
end

issues = ''
cmd = "git log #{log_rev_range} --pretty=\"format:%s\" | egrep \"#{issue_prefix}\" | cut -d \" \" -f 1 | sort | uniq"
logger.debug("Running #{cmd}")
stdout, stderr = run(cmd: cmd)
issues = stdout

logger.debug issues

# Tag with the new version
cmd = "git tag -a v#{new_version} -m \"#{new_version}\" -m \"Issues with commits, not necessarily closed: #{issues}\""
logger.debug("Running #{cmd}")
run(cmd: cmd)

# Push tags
cmd = "git push --tags"
logger.debug("Running #{cmd}")
run(cmd: cmd)

# Run a gem build
cmd = 'gem build cfn-nag.gemspec'
logger.debug("Running #{cmd}")
run(cmd: cmd)

# Push the gem
cmd = "gem push cfn-nag-#{new_version}.gem"
logger.debug("Running #{cmd}")
run(cmd: cmd)

# Publish docker image to DockerHub, https://hub.docker.com/r/stelligent/cfn_nag
cmd = "docker build -t #{ENV['docker_org']}/cfn_nag:#{new_version} ."
logger.debug("Running #{cmd}")
run(cmd: cmd)

# Login to docker
cmd = "docker login -u #{ENV['docker_user']} --password-stdin"
logger.debug("Running #{cmd}")
run(cmd: cmd, input: ENV['docker_password'])

# Tag docker image
cmd = "docker tag #{ENV['docker_org']}/cfn_nag:#{new_version} #{ENV['docker_org']}/cfn_nag:latest"
logger.debug("Running #{cmd}")
run(cmd: cmd)

# Push docker image
cmd = "docker push #{ENV['docker_org']}/cfn_nag:#{new_version}"
logger.debug("Running #{cmd}")
run(cmd: cmd)

cmd = "docker push #{ENV['docker_org']}/cfn_nag:latest"
logger.debug("Running #{cmd}")
run(cmd: cmd)
