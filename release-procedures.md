# Release Procedures

## Release kAppNav

This is done every four weeks in conjunction with Kabanero releases.

1. Ensure build/version.sh has the new release number (should have been done right after the previous release)
1. `cd operator; git checkout master; git pull; git checkout -b updateOperatorForNewRelease`
1. Create operator/releases/ subdirectory for the new release
1. Copy kappnav.yaml, kappnav-delete.yaml, and kappnav-delete-CR.yaml files from parent dir and replace KAPPNAV_VERSION with new release name
1. Copy the yaml files from the new release subdir to releases/latest
1. `git add .; git commit -m “Update release names in operator yaml files”; git push origin updateOperatorForNewRelease`
1. Create PR and merge to master
1. For each repo (apis, controller, operator, ui, README, build, samples, kappnav.github.io)
    - Identify the commit to release (usually HEAD but possibly an earlier commit)
    - `git checkout master` (for kappnav.github.io use the source branch instead)
    - `git pull`
    - `git tag -a <releaseTag> -m "Version <release>“` or if not HEAD add the commit hash to the end of the command
    - `git push origin <release tag>`
1. Visit each repo in github: select releases and then the tags button, create a release on the new tag
1. `cd build`
1. `./checkout.sh <releaseTag>`
1. `./build.sh`
1. `./pushKAppNavToDockerHub.sh`  (need write access to kappnav org in docker hub)
1. Edit build/version.sh to update the version to the next release level and merge to master


## Release App Navigator

This is done quarterly in conjunction with ICP4A.

1. Ensure version.sh has the new release number (should have been done right after the previous release)
2. Identify the commit to release (usually HEAD but possibly an earlier commit)
3. `git checkout master`
4. `git pull`
5. `git tag -a <releaseTag> -m "Version <release>“ <commit>   (e.g., git tag -a v0.1.4 -m "Version 0.1.4" a997895)`
6. `git push`
7. `git checkout <releaseTag>`
8. `./build.sh <kAppNav releaseTag>`
9. `./pushAppNavToStaging.sh  (need write access to IBM Entitled Registry)`
10. Edit version.sh to update the version to the next release level and merge to master
