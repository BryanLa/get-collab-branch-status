# get-collab-branch-status

This repo contains a tool and process for getting the review status info for all modified files in a collab branch, in a specific repository. This is a process that can be used by PR reviewers to isolate a set of files for review, within a collab branch, allowing the review process to occur on a more granular level.

The tool does the following:

1. Sets (and prompts for verification) that all Bash variables have been set correctly.
2. Checks out a fresh copy of the collab branch from the GitHub repo. If it doesn't exist locally yet it will create a copy of it.
3. Gets a list of the files in the open PR.
4. Walks the list of files and pulls the latest commit message for each file from the collab branch. The filename and commit message are output to the console by default, and can also be directed to a .csv file for analysis.

## Setup

These are all typically one-time steps, with the exception of #4 when doing reviews across multiple repos and/or collab branches.

1. Make sure you have a local clone of the repository that you'll be working with.
2. Verify that the following tools are installed:
   - Git Bash
      - See https://git-scm.com/downloads for the appropriate download and install.
   - JQ JSON processor
      - Open a Git Bash console under admin privileges
      - Copy, paste, and run the following statement in Git Bash:  
         `curl -L -o /usr/bin/jq.exe https://github.com/stedolan/jq/releases/latest/download/jq-win64.exe`

3. Download the `get-collab-branch-status.sh` Git Bash script from this repo, to the parent directory of your local repo clone subdirectories. For example, if the clone you downloaded in step #1 is in `c:\git\my-clone-repo`, the root directory where the Git Bash script should be downloaded is `c:\git`. 
4. Update the Bash variables at the top of the script file, including:
   - ORG: Set to the GitHub org of the repo
   - REPO: Set to the GitHub repo, in the org specified above
   - COLLAB_BRANCH: Set to the collab branch, in the repo specified above
   - PR: Set to the pull request number used to compare/merge the collab HEAD branch into the BASE branch. The BASE branch is ideally a release branch, but can also be `main`.
   - CSV_FILE_OUTPUT: If you'd like the script to log the file name and commit message output to a .csv file for analysis, set the value to `1`. Files are created in the same directory where you stored the script (in step #3), under the format: *"DDD, MMM DD,YYYY TIME.csv"*   
   - 
   `CSV_FILE_OUTPUT=1`  

## Usage

1. Open a Git Bash console and CD into the parent directory of your repo where the script lives, ie: `c:\git`.  
2. Run the script using: `./get-collab-branch-status.sh`  
3. The script will output the PR filenames and their last commit message to the console, and optionally to the .csv file.
4. Using the script output, identify which files should be reviewed:
   1. Files with a "REVIEW ..." commit message can be ignored, as these have not been updated since their last review.  
   2. Of the remaining files, identify the ones you'd like to isolate for review, typically 10 of them at most.
5. Mark the files to be reviewed
   1. Go to your local repo clone and check out the collab branch
   2. Mark the files identified in step #4 by applying a small change to them:  
      1. Markdown and YML files: one way is to add the `ms.lastreviewed: MM/DD/YYYY` metadata. This can also be used to track multiple review cycles for the given file and collab branch. 
      2. Image files: it may not be easy to apply an update so it's possible these should be batched up and reviewed later on their own.
6. Push the collab branch to your fork and open a PR against the main repo's collab branch. Review PRs should have a unique and consistent title prefix, as the title is used by the PR merge commit, which is the final commit message applied to all reviewed files. For example, "REVIEW: <description of review>". This is also the text you'll be looking for in step #4 above, when looking for files that need to be reviewed.
