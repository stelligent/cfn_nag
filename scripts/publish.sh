#!/bin/bash -ex
set -o pipefail
export minor_version="0.5"

set +x
if [[ -z ${rubygems_api_key} ]];
then
  echo rubygems_api_key must be set in the environment
  exit 1
fi
if [[ -z ${docker_user} ]];
then
  echo docker_user must be set in the environment
  exit 1
fi
if [[ -z ${docker_password} ]];
then
  echo docker_password must be set in the environment
  exit 1
fi
if [[ -z ${docker_org} ]];
then
  echo $docker_org must be set in the environment
  exit 1
fi
set -x

git config --global user.email "build@build.com"
git config --global user.name "build"

mkdir -p ~/.gem

set +ex
echo :rubygems_api_key: ${rubygems_api_key} > ~/.gem/credentials
set -ex
chmod 0600 ~/.gem/credentials

current_version=$(ruby -e 'tags=`git tag -l v#{ENV["minor_version"]}.*`' \
                       -e 'p tags.lines.map { |tag| tag.sub(/v#{ENV["minor_version"]}./, "").chomp.to_i }.max')

if [[ ${current_version} == nil ]];
then
  new_version="${minor_version}.0"
else
  new_version="${minor_version}.$((current_version+1))"
fi

sed -i.bak "s/0\.0\.0/${new_version}/g" cfn-nag.gemspec

#on circle ci - head is ambiguous for reasons that i don't grok
#we haven't made the new tag and we can't if we are going to annotate
head=$(git rev-parse HEAD)

issue_prefix='^#'
echo "Remember! You need to start your commit messages with #{issue_prefix}x, where x is the issue number your commit resolves."

if [[ ${current_version} == nil ]];
then
  log_rev_range=${head}
else
  log_rev_range="v${minor_version}.${current_version}..${head}"
fi

git log ${log_rev_range} --pretty="format:%s"
issues=$(git log ${log_rev_range} --pretty="format:%s" | \
         egrep "${issue_prefix}" | \
         cut -d " " -f 1 | sort | uniq)

git tag -a v${new_version} -m "${new_version}" -m "Issues with commits, not necessarily closed: ${issues}"

git push --tags

gem build cfn-nag.gemspec
gem push cfn-nag-${new_version}.gem

# publish docker image to DockerHub, https://hub.docker.com/r/stelligent/cfn_nag
docker build -t $docker_org/cfn_nag:${new_version} .
set +x
echo $docker_password | docker login -u $docker_user --password-stdin
set -x
docker tag $docker_org/cfn_nag:${new_version} $docker_org/cfn_nag:latest
docker push $docker_org/cfn_nag:${new_version}
docker push $docker_org/cfn_nag:latest

# publish vscode-remote docker image to DockerHub, https://hub.docker.com/r/stelligent/vscode-remote-cfn_nag
docker build -t $docker_org/vscode-remote-cfn_nag:${GEM_VERSION} --file .devcontainer/build/Dockerfile .
set +x
echo $docker_password | docker login -u $docker_user --password-stdin
set -x
docker tag $docker_org/vscode-remote-cfn_nag:${new_version} $docker_org/vscode-remote-cfn_nag:latest
docker push $docker_org/vscode-remote-cfn_nag:${new_version}
docker push $docker_org/vscode-remote-cfn_nag:latest
