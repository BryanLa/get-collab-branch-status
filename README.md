# get-collab-branch-status

This repo contains a Git Bash script and process for managing pull request (PR) reviews of contributions against a collaboration (aka: collab) branch.

Changes in collab branches can be difficult for PR reviewers to process, given that contributors can sign-off and merge work without getting final PR review. This is especially true as collab branch commits accumulate over time, impacting 10s or 100s of files. Although this is more common in collab branches, this script/process can be used to chunk up reviews of large contributions in any branch (whenever a practical limit has been exceeded), before it's merged back into a BASE branch. 

This process preserves all of the original commit history that has occurred in the collab branch, by:

1. Using the script to generate the list of collab branch files that have been added, updated, or deleted, including details of the latest commit for each file. The list is essentially a diff between the collab branch and a BASE ancestor (ie: release-* or main). The commit message is used to filter out files that don't require review, as indicated by a standard prefix such as `REVIEWED: <message>` or similar.
2. Identifying a subset of files from the list for review, as determined by the lack of the commit message prefix. 
3. Marking the subset of files for review by applying a small commit, allowing the files to be included in a review PR against the collab branch.
4. Reviewing the PR files and applying a final `REVIEWED: <message>` commit to them, then merging them back into the collab branch.

## Prerequisites and setup

First make sure a GitHub PR has been opened to compare/merge the collab HEAD branch into a BASE branch. The BASE branch is ideally a release branch, but can also be `main`.

On the machine where the script is run, complete the following steps:

1. Verify that the following are installed on your local machine:
   - Git Bash: See https://git-scm.com/downloads for the appropriate download and install.
   - JQ JSON processor: Open a Git Bash console under admin privilege then copy/paste, and run the following statement in Git Bash:
         `curl -L -o /usr/bin/jq.exe https://github.com/stedolan/jq/releases/latest/download/jq-win64.exe`
     > NOTE: curl is preinstalled on Win10 and Win11. See [this post](https://stackoverflow.com/a/16216825) if you need to install.

2. Create a local clone of the GitHub repository that contains the collab branch.

3. Download the [`get-collab-branch-status.sh` script](https://github.com/BryanLa/get-collab-branch-status/blob/main/get-collab-branch-status.sh), to the parent directory of your local clone subdirectory. For example, if the clone created in step #2 is in `c:\git\my-clone-repo`, the root directory where the script should be downloaded is `c:\git`.  

4. Open the script file in an editor and update the Bash variables at the top of the file accordingly:
   - `ORG`: Set to the GitHub org of the repo that contains the collab branch
   - `REPO`: Set to the repo that contains the collab branch
   - `COLLAB_BRANCH`: Set to the collab branch where you're doing reviews
   - `PR`: Set to the PR number that compares the collab/HEAD branch with the BASE branch.
   - `CSV_FILE_OUTPUT`: Set to `1` to log the file name and commit info to a .csv file for analysis. Files are created in the same directory where you stored the script in step #3, in the format: *"DDD, MMM DD,YYYY TIME.csv"*   

## Usage

1. Open a Git Bash console and CD into the parent directory of your repo where the script lives, ie: `c:\git`.  

2. The script uses the `gh api` command, which requires GitHub authentication. You can either run `gh auth login` and follow the prompts to authenticate with your GitHub account, or create a [Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) and assign it to the GITHUB_TOKEN environment variable. It's not recommended to keep the GITHUB_TOKEN variable assignment in the script for security reasons.

2. Run the script using: `./get-collab-branch-status.sh`. The script will:  
   1. Set several variables and prompt for verification of their values.
   2. Check out a fresh copy of the collab branch. If it doesn't exist locally yet it will create a copy of it.
   3. Get a list of the files that have been modified in the collab branch.
   4. Walk the list of files and pull the latest commit message for each file. The filename and commit message are output to the console by default, and can also be directed to a .csv file for analysis.

3. Using the script output, identify the files to be reviewed:  
   1. Files with a "REVIEWED" commit message can be ignored, as these have not been updated since their last review.  
   2. Of the remaining files, identify the added/modified files to be isolated for review, typically 10 at a time. Files with a state of "A" are new/added files, "M" are modified files, and "D" are deleted files. 

4. Mark the files to be reviewed:  
   1. CD into your local clone subdirectory and check out the collab branch.  
   2. Mark the files identified in step #3 by applying a small change to them:  
      **New/modified text files (.MD, .YML, .JSON)**: these just need to have a small update, such as a space added to the end of a line. For Markdown and YML files that support metadata, a better way is to add the `ms.lastreviewed: MM/DD/YYYY` metadata. This can also be used to track multiple review cycles for the given file and collab branch. 
      
      **New/modified image files**: these are difficult to "mark" and should really be reviewed in the context of the host articles. As such, the PR reviewer can provide feedback in the review PR (created in the next step), indicating whether changes need to be made.   

5.  Push the collab branch to your fork and open a PR against the main repo's collab branch. As PR reviewers review/update the files in the PR and collaborate with contributors, they'll need to touch all of the PR's files, and apply a consistent commit message prefix, for example, "REVIEWED: <description of updates>" or similar. This is also the text you'll be looking for in step #3 above, when looking for files that need to be reviewed.  

## Troubleshooting

#### cd: cloud-adoption-framework-pr: No such file or directory

If you see the following output, you are running the script from the wrong directory. This script must be run from the local repo's parent directory:   
   ```   
   Getting a fresh local copy of collab branch: collab-cafmigrate-wave2 ...
   ../get-collab-branch-status.sh: line 42: cd: cloud-adoption-framework-pr: No such file or directory
   ```  

#### gh: Not Found (HTTP 404) ####

If you see the following output, you have not authenticated with GitHub correctly. See step #2 of the Usage section above for instructions:
   ```   
   Getting a list of files in PR: <PR#> ...
   gh: Not Found (HTTP 404)
   ```   


