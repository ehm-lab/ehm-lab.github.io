# Making changes and publishing the ehm-lab.github.io

Hey there, I hope you are here becasue you have made some changes to this repo (which you know produces and serves our lab website to the internet) and now you want the repo and/or the website to be updated accordingly.

To update repo and github.io site -> Commit-Push your changes to the main branch then wait for the auto-render-publish workflow to run (anywhere from 1 to 15 minutes).  
To update repo but not site -> add [skip ci] to the commit message.  
To update the site -> go to Actions above, on the left select the Deploy Quarto workflow, then click Run Workflow on the right (it should be default to run from the main branch)  
*this third option does not have much utlity, but for example, it can be used if you've push-committed with a [skip-ci] and now realize you want to re-render the site to see the updates

To see what the changes you've made to the .qmd files that underpin the site would look like online, use `quarto render` in the Terminal of the IDE
