#!/bin/bash -ex
set -o pipefail

current_version=$(ruby -e 'tags=`git tag -l v0\.0\.*`' \
                       -e 'p tags.lines.map { |tag| tag.sub(/v0.0./, "").chomp.to_i }.max')

if [[ ${current_version} == nil ]];
then
  new_version='0.0.1'
else
  new_version=0.0.$((current_version+1))
fi

#more generally bsd/gnu sed
if [[ ${_system_name} == OSX ]];
then
  sed -i .bak  "s/0\.0\.0/${new_version}/g" cfn-nag.gemspec
else
  sed -i "s/0\.0\.0/${new_version}/g" cfn-nag.gemspec
fi

cat cfn-nag.gemspec

#on circle ci - head is ambiguous for reasons that i don't grok
#we haven't made the new tag and we can't if we are going to annotate
head=$(git log -n 1 --oneline | awk '{print $1}')

echo "Remember! You need to start your commit messages with CS-xx, where x is the issue number your commit resolves."
issue_prefix='^CS-\d'

if [[ ${current_version} == nil ]];
then
  log_rev_range=${head}
else
  log_rev_range="v0.0.${current_version}..${head}"
fi

issues=$(git log ${log_rev_range} --oneline | awk '{print $2}' | grep "${issue_prefix}" | uniq)

echo issues: $issues

git tag -a v${new_version} -m " " -m "Issues with commits, not necessarily closed: ${issues}"

git push --tags

#gem build cfn-nag.gemspec
#gem push cfn-nag-*.gem