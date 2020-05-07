#!/bin/bash -ex
set -o pipefail
export minor_version="0.6"

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

# publish rubygem to rubygems.org, https://rubygems.org/gems/cfn-nag
gem build cfn-nag.gemspec
gem push cfn-nag-${new_version}.gem

# publish docker image to DockerHub, https://hub.docker.com/r/stelligent/cfn_nag
docker build -t $docker_org/cfn_nag:${new_version} . --build-arg version=${new_version} -f Dockerfile.local
set +x
echo $docker_password | docker login -u $docker_user --password-stdin
set -x
docker tag $docker_org/cfn_nag:${new_version} $docker_org/cfn_nag:latest
docker push $docker_org/cfn_nag:${new_version}
docker push $docker_org/cfn_nag:latest

echo "::set-output name=cfn_nag_version::${new_version}"
