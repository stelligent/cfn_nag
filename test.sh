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

echo $GEM_VERSION
