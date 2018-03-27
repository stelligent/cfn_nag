#!/bin/bash -ex
set -o pipefail

set +x
if [[ -z ${rubygems_api_key} ]];
then
  echo rubygems_api_key must be set in the environment
  exit 1
fi
set -x

git config --global user.email "build@build.com"
git config --global user.name "build"

set +ex
echo :rubygems_api_key: ${rubygems_api_key} > ~/.gem/credentials
set -ex
chmod 0600 ~/.gem/credentials

# git describe returns the latest tag
current_tag=$(git describe)

# Check if '-' in git describe. If so, we
# have advanced past the latest tag (and will
# need to compute new version)
tagged_commit=1
if echo $current_tag | grep -q '-'; then
  tagged_commit=0
fi

# strip off initial 'v' and everything after digits and .
current_version=$(git describe | sed 's/^\(v\)\([0-9.]*\).*$/\2/')
# strip .### from end to get major.minor version
current_minor=$(echo $current_version | sed 's/\.\([0-9]*\)$//')
# get third dotted field for patch version
current_patch=$(echo $current_version | cut -f 3 -d . )

if [[ ${current_version} == nil ]];
then
  # No version determined from tag, assume 0.0.0
  GEM_VERSION='0.0.0'
elif [ $tagged_commit = 1 ]; then
  # Current commit was tagged with version, use it
  GEM_VERSION=$current_version
else
  # Current commit was goes past a tag, increment patch
  GEM_VERSION="$current_minor."$((current_patch + 1))
fi

export GEM_VERSION

#on circle ci - head is ambiguous for reasons that i don't grok
#we haven't made the new tag and we can't if we are going to annotate
head=$(git rev-parse HEAD)

issue_prefix='^#'
echo "Remember! You need to start your commit messages with #{issue_prefix}x, where x is the issue number your commit resolves."

if [[ ${current_version} == nil ]];
then
  log_rev_range=${head}
else
  log_rev_range="v${current_version}..${head}"
fi

export issues=""$(git log ${log_rev_range} --oneline | awk '{print $2}' | grep "${issue_prefix}" | uniq)

if [ $tagged_commit = 0 ]; then
  git tag -a "v${GEM_VERSION}" -m "${GEM_VERSION}" -m "Issues with commits, not necessarily closed: ${issues}"
  git push --tags
fi

# gemspec respects GEM_VERSION envvar
gem build cfn-nag.gemspec
gem push cfn-nag-${GEM_VERSION}.gem
