#!/bin/sh -e

# This is a script that helps automate the daily task of creating
# a new branch for the issue being worked on and a Draft PR for said branch.
#
# This script makes assumptions about your local dev enviornment.
# Specifically it expects a configured GitHub CLI install and the JSON tool `jq`.

# Verify you are on the main branch.
current_branch=$(git symbolic-ref --short HEAD)
if [ "$current_branch" != "main" ]; then
  echo "This script can only be used from the main branch."
  exit 1
fi

# Ask what issue number you want to start.
read -p "Issue Number: " issue_number

# Verify the issue is real and grab the title for later.
issue_title=$(gh issue view $issue_number --json title | jq -r '.title')

# Kick out issues that do not exsit.
# GraphQL: Could not resolve to an issue or pull request with the number of 999. (repository.issue)
if [[ "${issue_title:0:8}" = "GraphQL:" ]]; then
    echo "Could not verify that is an actual issue."
    exit
fi

# TODO: We might warn if referencing an issue that has already been started or closed by someone else.

# Prompt the user for a branch name, but offer a sensible default.
default_branch_name="issue-$issue_number"
read -p "Enter a branch name (default is '$default_branch_name'): " branch_name

# If the user provided no input, use the default value.
if [ -z "$branch_name" ]; then
  branch_name=$default_branch_name
fi

echo "Creating branch"
$(git checkout -b $branch_name)

# Make a notes file so we can have a commit in place (which is sadly a requirement for a PR).
note_filename="$branch_name-notes.md"
echo $(touch ../$note_filename)
echo $(git add ../$note_filename)
echo $(git commit -m "adding notes file")

echo "Pushing branch"
echo $(git push origin $branch_name)

echo "Creating PR"
# By using the term "Fixes #N" GitHub will auto link the issue to the PR.
echo $(gh pr create -d --title "[Fixes #$issue_number] $issue_title" --body "Fixes #$issue_number")
