# Gitflow Workflow as used by AppNav Dev Team

## To setup project directory on dev machine: 

1. git clone https://github.ibm.com/WASCloudPrivate/prism.git
1. cd prism
1. git clone https://github.ibm.com/WASCloudPrivate/helm-chart-prism.git

## To develop an issue - e.g. in prism repo

Setup branch: 

1. cd prism
1. git checkout integration
1. git pull
1. git checkout -b issue#nnn [optional short description]

Make changes.

Check in work: 

1. git add . 
1. git commit -m 'comment about what you changed'
1. git push origin issue#nnn [optional short description]

In Git: 

1. create a PR to integreate issue#nnn into integration - i.e. integration <- issue#nnn 
1. have your PR peer-reviewed 
1. ensure your builds are successful 
1. merge your PR and delete your branch (issue#nnn [optional short description]) 
