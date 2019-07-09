#!/bin/bash
PR_URL=$(echo $CIRCLE_PULL_REQUEST | sed -e 's!github.com!api.github.com/repos!' -e 's!pull!pulls!' )
curl -s -H "Authorization: token $GITHUB_API_TOKEN"  $PR_URL 
PR_TITLE=$(curl -s -H "Authorization: token $GITHUB_API_TOKEN"  $PR_URL | jq -r '.title' )

if echo $PR_TITLE | grep -v -q -E  '^#[0-9]+' 
then
  echo "ERROR: PR Title ($PR_TITLE) needs to start with a issue number (example: #123 )"
  exit 1
fi
