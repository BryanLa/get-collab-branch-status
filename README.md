# get-collab-branch-status

This repo contains a Git Bash script and process for listing the review status of all files in a collaboration (aka: collab) branch, allowing a subset of the files to be isolated in a pull request (PR) for review. This process can be used by PR reviewers to chunk files for review, allowing the review process to occur on a more granular level rather than all modified files. This is especially useful in collab branches where contributors can merge PRs without final review by the PR review team. In reality, it could be used to chunk up unreviewed work in any branch though.

The script runs locally and:

1. Sets several variables and prompt for verification of their values.
2. Checks out a fresh copy of the collab branch. If it doesn't exist locally yet it will create a copy of it.
3. Gets a list of the files that have been modified in the collab branch.
4. Walks the list of files and pull the latest commit message for each file. The filename and commit message are output to the console by default, and can also be directed to a .csv file for analysis.

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

2. The script uses the `gh api` command, which requires GitHub authentication. You can either run `gh auth login` and follow the prompts to authenticate with your GitHub account. Or create a [Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens) and assign it to the GITHUB_TOKEN environment variable. It's not recommended to keep the GITHUB_TOKEN variable assignment in the script for security reason.

2. Run the script using: `./get-collab-branch-status.sh`. The script will output the PR filenames and commit info to the console, and optionally to the .csv file.  

3. Using the script output, identify the files to be reviewed:  
   1. Files with a "REVIEWED" commit message can be ignored, as these have not been updated since their last review.  
   2. Of the remaining files, identify the added/modified files to be isolated for review, typically 10 at a time. Files with a state of "A" are new/added files, "M" are modified files, and "D" are deleted files. 

4. Mark the files to be reviewed:  
   1. CD into your local clone subdirectory and check out the collab branch.  
   2. Mark the files identified in step #3 by applying a small change to them:  
      **New/modified text files (.MD, .YML, .JSON)**: these just need to have a small update, such as a space added to the end of a line. For Markdown and YML files that support metadata, a better way is to add the `ms.lastreviewed: MM/DD/YYYY` metadata. This can also be used to track multiple review cycles for the given file and collab branch. 
      
      **New/modified image files**: these are difficult to "mark" and should really be reviewed in the context of the host articles. As such, the PR reviewer can provide feedback in the review PR (created in the next step), indicating whether changes need to be made.   

5. Push the collab branch to your fork and open a PR against the main repo's collab branch. As PR reviewers review/update the files in the PR and collaborate with contributors, they'll need to touch all of the PR's files, and apply a consistent commit message prefix, for example, "REVIEWED: <description of updates>" or similar. This is also the text you'll be looking for in step #3 above, when looking for files that need to be reviewed.  
