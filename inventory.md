# Inventory Command Action

The inventory command action is a kAppNav-wide command.  It does not apply to any application or application component. 
It lists Kuberentes resources belonging to, or under the control of, kAppNav: 

1. All resources in the kappnav namespace.
1. All application resources and their components.

## Container Image

The inventory container image contains these tools: 

1. kubectl 
1. Maven
1. Node.js
1. OpenLiberty

The inventory also contains a copy of the kAppNav API server. 

## Command Action Definition

The command action definition is stored in this [action config map](https://github.com/kappnav/operator/blob/master/deploy/maps/action/configmap.action.application.kappnav.yaml)
This command is defined as an "application" level action.  A new "kappnav" application is now created by the kAppNav operator. 
The kappnav application is marked as [hidden application]() to serve as an anchor for kAppNav-wide command actions, without 
appearing in the application list. 

## UI Support 

The UI will display command actions defined to the kAppNav application on the Command Action page.  When no command actions 
have been run, the command action page is empty and will display an instructive statement, inviting the user to submit the 
inventory action.  

This page will also display a list of kAppNav-wide command actions in a drop down list on the upper right 
of the page.  The initial implementation will be just a single button to run the inventory command. When more
actions are defined, this button will be converted into an actual drop down list. 

[!default](https://github.com/kappnav/design/blob/master/images/default-command-actions.png)

