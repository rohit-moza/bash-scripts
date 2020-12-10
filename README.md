Updated Dec 10, 2020

# Handy GitHub helpers
- copy all files to ~/bin
- perform chmod +x .* or only for the bash scripts you want to give access to execute. 

Commands 
1. gnb - capture branch type and branch name from user and checks out the branch with the new naming accordingly
2. gnb - Asks for new commit message and pushes all new files changed in commit to branch where command was called from
3. gnr - Pulls latest changes to master assuming the PR to master has already been merged in remotely and then asks user to tag it. Provides current tag version so user can choose the next tag accordingly
4. gpl - Pull latest changes from the branch calling this command
