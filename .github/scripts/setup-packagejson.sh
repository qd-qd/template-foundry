#!/usr/bin/env bash

# https://gist.github.com/vncsna/64825d5609c146e80de8b1fd623011ca
set -euo pipefail

# Define the input vars
GITHUB_REPOSITORY=${1?Error: Please pass username/repo, e.g. prb/foundry-template}
GITHUB_REPOSITORY_OWNER=${2?Error: Please pass username, e.g. prb}
GITHUB_REPOSITORY_DESCRIPTION=${3:-""} # If null then replace with empty string

echo "GITHUB_REPOSITORY: $GITHUB_REPOSITORY"
echo "GITHUB_REPOSITORY_OWNER: $GITHUB_REPOSITORY_OWNER"
echo "GITHUB_REPOSITORY_DESCRIPTION: $GITHUB_REPOSITORY_DESCRIPTION"

# Create a new package.json file with the new values
JQ_OUTPUT_PACKAGE=$(
  jq \
    --arg NAME "@$GITHUB_REPOSITORY" \
    --arg AUTHOR "$GITHUB_REPOSITORY_OWNER https://github.com/$GITHUB_REPOSITORY_OWNER" \
    --arg REPOSITORY "github:@$GITHUB_REPOSITORY" \
    --arg BUGS "https://github.com/$GITHUB_REPOSITORY/issues" \
    --arg HOMEPAGE "https://github.com/$GITHUB_REPOSITORY#readme" \
    --arg VERSION "0.0.1" \
    --arg DESCRIPTION "$GITHUB_REPOSITORY_DESCRIPTION" \
    '.name = $NAME | .author = $AUTHOR | .repository = $REPOSITORY |
    .bugs = $BUGS | .homepage = $HOMEPAGE | .version = $VERSION | .description = $DESCRIPTION' \
    package.json
)

# Create a new package-lock.json file with the new values
JQ_OUTPUTPACKAGE_LOCK=$(
  jq \
    --arg VERSION "0.0.1" \
    '.version = $VERSION | .packages."".version = $VERSION' \
    package-lock.json
)

# Save the new version of the package.json and package-lock.json files
echo "$JQ_OUTPUT_PACKAGE" >package.json
echo "$JQ_OUTPUTPACKAGE_LOCK" >package-lock.json

# Make sed command compatible in both Mac and Linux environments
# Reference: https://stackoverflow.com/a/38595160/8696958
sedi() {
  sed --version >/dev/null 2>&1 && sed -i -- "$@" || sed -i "" "$@"
}

# Rename instances of "qd-qd/template-foundry" to the new repo name in README.md for badges only
sedi "/github-editor-url/ s|qd-qd/template-foundry|"${GITHUB_REPOSITORY}"|;" "README.md"
sedi "/gha-quality-url/ s|qd-qd/template-foundry|"${GITHUB_REPOSITORY}"|;" "README.md"
sedi "/gha-quality-badge/ s|qd-qd/template-foundry|"${GITHUB_REPOSITORY}"|;" "README.md"
sedi "/gha-test-url/ s|qd-qd/template-foundry|"${GITHUB_REPOSITORY}"|;" "README.md"
sedi "/gha-test-badge/ s|qd-qd/template-foundry|"${GITHUB_REPOSITORY}"|;" "README.md"
sedi "/gha-static-analysis-url/ s|qd-qd/template-foundry|"${GITHUB_REPOSITORY}"|;" "README.md"
sedi "/gha-static-analysis-badge/ s|qd-qd/template-foundry|"${GITHUB_REPOSITORY}"|;" "README.md"
sedi "/gha-release-url/ s|qd-qd/template-foundry|"${GITHUB_REPOSITORY}"|;" "README.md"
sedi "/gha-release-badge/ s|qd-qd/template-foundry|"${GITHUB_REPOSITORY}"|;" "README.md"
