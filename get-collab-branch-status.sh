#!/bin/bash

# Variables
ORG="MicrosoftDocs"                 # Change to $1 to populate via command line parameters
REPO="cloud-adoption-framework-pr"  # Change to $2 to populate via command line parameters
COLLAB_BRANCH="collab-govern"       # Change to $3 to populate via command line parameters
PR="5286"                           # Change to $4 to populate via command line parameters; NOTE THIS IS THE COLLAB-TO-RELEASE PR
COLLAB_BRANCH_REMOTE="upstream"     # Typically left as "upstream"
TIMESTAMP=$(date)
CSV_FILE_OUTPUT=1                   # 0=no, 1=yes
DEBUG=1                             # 0=no, 1=yes

# Usage
if [ -z "$ORG" ] || [ -z "$REPO" ] || [ -z "$COLLAB_BRANCH" ] || [ -z "$PR" ]; then
    echo "One or more command line arguments is empty"
    echo "Usage: get-collab-files-status <GitHub Org> <GitHub Repo> <Collab branch> <Pull request>"
    echo "Gets the list of files from a collab branch and their review status"
    exit
fi

# Prompt the user
clear
echo "Organization: $ORG"
echo "Repository: $REPO"
echo "Collab branch: $COLLAB_BRANCH_REMOTE / $COLLAB_BRANCH"
echo "Pull request: $PR"
echo "This script must be run from the parent directory of the $REPO subdirectory."
echo "Press ENTER if you're ready, otherwise CTRL-C to cancel ..."
read -p ""

# Checkout and update the local collab branch
echo
echo "Getting a fresh local copy of collab branch: $COLLAB_BRANCH ..."
cd $REPO
# git fetch $COLLAB_BRANCH_REMOTE 
# git checkout --track $COLLAB_BRANCH_REMOTE/$COLLAB_BRANCH
# git pull $COLLAB_BRANCH_REMOTE $COLLAB_BRANCH

if [[ $(git ls-remote --heads $COLLAB_BRANCH_REMOTE refs/heads/"$COLLAB_BRANCH") == "" ]]; then 
    echo $'Branch "'$COLLAB_BRANCH'" does not exist in the "'$COLLAB_BRANCH_REMOTE'" remote. Correct the issue and rerun. Exiting the script.'
    exit
else
  if [[ $(git branch --list $COLLAB_BRANCH) == "" ]]; then # Branch does not exist locally
    if [ $DEBUG == 1 ]; then echo "Branch does not exist locally - create it from the remote"; fi
    git fetch --force $COLLAB_BRANCH_REMOTE $COLLAB_BRANCH
    git checkout --track $COLLAB_BRANCH_REMOTE/$COLLAB_BRANCH
  else  # Branch does exist locally
    if [ $DEBUG == 1 ]; then echo "Branch does exist locally - pull the latest commits"; fi
    git checkout $COLLAB_BRANCH
    git pull $COLLAB_BRANCH_REMOTE $COLLAB_BRANCH
  fi
fi

# Get list of files in the pull request
echo
echo "Getting a list of files in PR: $PR ..."
files=$(gh pr view $PR --json files --jq '.files[].path' -R $ORG/$REPO)
if [ -z "$files" ]; then
    echo "Invalid PR or no files found in the pull request."
    exit 1
fi

# Iterate over the files, print file name and latest commit message
echo
echo "Listing all file names and their latest commits ..."
if [ $CSV_FILE_OUTPUT == 1 ]; then echo "Filename,Last commit message,Author,State" > ..\\"$TIMESTAMP.csv"; fi

for filename in $files; do
  message=$(git log -1 --pretty=format:"%s, %an," --name-status -- "$filename" | awk '{if(NR==1) print $0; else if(NR==2) print $1;}' | tr '\n' ' ')
  echo "File: $filename"
  echo "Commit message: $message"
  if [ $CSV_FILE_OUTPUT == 1 ]; then echo "$filename,$message" >> ..\\"$TIMESTAMP.csv"; fi
done

cd ..