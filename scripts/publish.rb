#!/usr/bin/ruby
#set -o pipefail

require 'logger'
require 'fileutils'
require 'open3'

#!/bin/bash -ex
#set -o pipefail
#export minor_version="0.5"
major_version = "0"
minor_version = "5"

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

#set +x
#if [[ -z ${rubygems_api_key} ]];
#then
#  echo rubygems_api_key must be set in the environment
#  exit 1
#fi
#if [[ -z ${docker_user} ]];
#then
#  echo docker_user must be set in the environment
#  exit 1
#fi
#if [[ -z ${docker_password} ]];
#then
#  echo docker_password must be set in the environment
#  exit 1
#fi
#if [[ -z ${docker_org} ]];
#then
#  echo $docker_org must be set in the environment
#  exit 1
#fi
#set -x

failed = 0
["rubygems_api_key", "docker_user", "docker_password", "docker_org"].each do |v|
  if ENV[v] == nil
    puts "#{v} must be set in the environment"
    failed = 1
  end
end
exit 1 if failed > 0

#git config --global user.email "build@build.com"
#git config --global user.name "build"

logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG
#git config --global user.email "build@build.com"
#git config --global user.name "build"
cmd='git config --global user.email "build@build.com" && '\
    'git config --global user.name "build"'
run(cmd: cmd)

#Git.global_config('user.name', 'build')
#Git.global_config('user.email', 'build@build.com')

#mkdir -p ~/.gem

#set +ex
#echo :rubygems_api_key: ${rubygems_api_key} > ~/.gem/credentials
#set -ex
#chmod 0600 ~/.gem/credentials

gem_dir = File.join(Dir.home, ".gem")
Dir.mkdir(gem_dir) unless File.exists?(gem_dir)
creds_file = File.join(Dir.home, ".gem", "credentials")
File.write(creds_file, ":rubygems_api_key: #{ENV['rubygems_api_key']}\n")
FileUtils.chmod(0600, creds_file)

#current_version=$(ruby -e 'tags=`git tag -l v#{ENV["minor_version"]}.*`' \
#                       -e 'p tags.lines.map { |tag| tag.sub(/v#{ENV["minor_version"]}./, "").chomp.to_i }.max')

# Find the largest patch version of the minor version
# I.e. if minor version is 4 and there is a v0.4.0 - v0.4.82, then return 82
cmd = "git tag -l v#{major_version}.#{minor_version}.*"
stdout, stderr = run(cmd: cmd)
tags = stdout
#logger.debug "tags = #{tags}"
patch_version = tags.lines.map { |tag| tag.sub(/v#{major_version}.#{minor_version}./, "").chomp.to_i }.max
logger.debug "patch_version = #{patch_version}"
#tags=g.tags.map{|e| e.name}

new_version = "#{major_version}.#{minor_version}.#{patch_version}"
logger.debug("Found next version to be #{new_version}")

#if [[ ${current_version} == nil ]];
#then
#  new_version="${minor_version}.0"
#else
#  new_version="${minor_version}.$((current_version+1))"
#fi

#sed -i.bak "s/0\.0\.0/${new_version}/g" cfn-nag.gemspec

cmd = "sed -i.bak \"s/0\.0\.0/#{new_version}/g\" cfn-nag.gemspec"
logger.debug("Running #{cmd}")
run(cmd: cmd)


##on circle ci - head is ambiguous for reasons that i don't grok
##we haven't made the new tag and we can't if we are going to annotate
#head=$(git rev-parse HEAD)
cmd = "git rev-parse HEAD"
head, stderr = run(cmd: cmd)
logger.debug("head = #{head}")

#issue_prefix='^#'
#echo "Remember! You need to start your commit messages with #{issue_prefix}x, where x is the issue number your commit resolves."
issue_prefix='^#'
logger.info("Remember! You need to start your commit messages with #{issue_prefix}x, where x is the issue number your commit resolves.")

#if [[ ${current_version} == nil ]];
#then
#  log_rev_range=${head}
#else
#  log_rev_range="v${minor_version}.${current_version}..${head}"
#fi

#issues=$(git log ${log_rev_range} --pretty="format:%s" | \
#         egrep "${issue_prefix}" | \
#         cut -d " " -f 1 | sort | uniq)

log_rev_range = head
log_rev_range = "v#{new_version}..#{head}" if patch_version != "0"

issues = ''
cmd = "git log #{log_rev_range} --pretty=\"format:%s\" | egrep \"#{issue_prefix}\" | cut -d \" \" -f 1 | sort | uniq"
logger.debug("Running #{cmd}")
stdout, stderr = run(cmd: cmd)
issues = stdout

logger.debug issues

exit

#git tag -a v${new_version} -m "${new_version}" -m "Issues with commits, not necessarily closed: ${issues}"

cmd = "git tag -a v#{new_version} -m \"#{new_version}\" -m \"Issues with commits, not necessarily closed: #{issues}\""
logger.debug("Running #{cmd}")
run(cmd: cmd)

#git push --tags
cmd = "git push --tags"
logger.debug("Running #{cmd}")
run(cmd: cmd)


#gem build cfn-nag.gemspec
cmd = 'gem build cfn-nag.gemspec'
logger.debug("Running #{cmd}")
run(cmd: cmd)
#gem push cfn-nag-${new_version}.gem
cmd = "gem push cfn-nag-#{new_version}.gem"
logger.debug("Running #{cmd}")
run(cmd: cmd)

# publish docker image to DockerHub, https://hub.docker.com/r/stelligent/cfn_nag
#docker build -t $docker_org/cfn_nag:${new_version} .
cmd = "docker build -t $docker_org/cfn_nag:#{new_version} ."
logger.debug("Running #{cmd}")
run(cmd: cmd)
#set +x
#echo $docker_password | docker login -u $docker_user --password-stdin
#set -x
cmd = "docker login -u $docker_user --password-stdin"
logger.debug("Running #{cmd}")
run(cmd: cmd, input: docker_password)
#docker tag $docker_org/cfn_nag:${new_version} $docker_org/cfn_nag:latest
cmd = "docker tag #{docker_org}/cfn_nag:#{new_version} #{docker_org}/cfn_nag:latest"
logger.debug("Running #{cmd}")
run(cmd: cmd)
#docker push $docker_org/cfn_nag:${new_version}
cmd = "docker push #{docker_org}/cfn_nag:#{new_version}"
logger.debug("Running #{cmd}")
run(cmd: cmd)
#docker push $docker_org/cfn_nag:latest
cmd = "docker push ${docker_org}/cfn_nag:latest"
logger.debug("Running #{cmd}")
run(cmd: cmd)
