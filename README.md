# get-collab-branch-status

This repo contains a tool and process for listing the review status of all modified files in a collab branch, then bring a subset of those files into a pull request (PR) for review. This is a process that can be used by PR reviewers to isolate/chunk files for review, allowing the review process to occur on a more granular level.

The tool will:

1. Set all Bash variables and prompt for verification of their values.
2. Check out a fresh copy of the collab branch. If it doesn't exist locally yet it will create a copy of it.
3. Get a list of all files that have been modified in the collab branch.
4. Walk the list of files and pull the latest commit message for each file. The filename and commit message are output to the console by default, and can also be directed to a .csv file for analysis.

## Setup

These are typically one-time steps, with the exception of #4 if doing reviews across multiple repos and/or collab branches:

1. For the repository that you'll be working in, verify the following:
   - A GitHub PR has been opened to compare/merge the collab HEAD branch into the BASE branch. The BASE branch is ideally a release branch, but can also be `main`.
   - You have a local clone of the repository  
2. Verify that the following tools are installed on your local machine:
   - Git Bash: See https://git-scm.com/downloads for the appropriate download and install.
   - JQ JSON processor:
      - Open a Git Bash console under admin privilege
      - Copy, paste, and run the following statement in Git Bash:  
         `curl -L -o /usr/bin/jq.exe https://github.com/stedolan/jq/releases/latest/download/jq-win64.exe`

3. Download the `get-collab-branch-status.sh` Git Bash script from this repo, to the parent directory of your local repo clone subdirectory. For example, if the clone you downloaded in step #1 is in `c:\git\my-clone-repo`, the root directory where the Git Bash script should be downloaded is `c:\git`.  
4. Update the Bash variables at the top of the script file, including:
   - `ORG`: Set to the GitHub org of the repo where you're doing reviews
   - `REPO`: Set to the GitHub repo, in the org specified above
   - `COLLAB_BRANCH`: Set to the collab branch, in the repo specified above
   - `PR`: Set to the PR number identified in step #1
   - `CSV_FILE_OUTPUT`: Set to `1` if you'd like the script to log the file name and commit message output to a .csv file for analysis. Files are created in the same directory where you stored the script in step #3, in the format: *"DDD, MMM DD,YYYY TIME.csv"*   

## Usage

1. Open a Git Bash console and CD into the parent directory of your repo where the script lives, ie: `c:\git`.  
2. Run the script using: `./get-collab-branch-status.sh`. The script will output the PR filenames and their last commit message to the console, and optionally to the .csv file.  
3. Using the script output, identify the files to be reviewed:  
   1. Files with a "REVIEWED" commit message can be ignored, as these have not been updated since their last review.  
   2. Of the remaining files, identify the ones you'd like to isolate for review, typically 10 of them at most.  
   3. Optionally, communicate the list of files to all contributors, asking them to commit/push any unapplied updates and refrain from updating the files.
4. Mark the files to be reviewed:  
   1. CD into your local repo clone and check out the collab branch.  
   2. Mark the files identified in step #3 by applying a small change to them:  
      1. Markdown and YML files: one way is to add the `ms.lastreviewed: MM/DD/YYYY` metadata. This can also be used to track multiple review cycles for the given file and collab branch.  
      2. Image files: it may not be easy to apply an update so it's possible these should be batched up and reviewed later on their own.  
5. Push the collab branch to your fork and open a PR against the main repo's collab branch. As PR reviewers review/update the files in the PR, they'll need to use a consistent commit message format, for example, "REVIEWED: <description of updates>", or similar. This is also the text you'll be looking for in step #3 above, when looking for files that need to be reviewed.  
