# Appsody Exploitation of Detail Sections and Action Enablement

Appsody will make use of kAppNav detail sections and action enablement.  

## Detail Sections

kAppNav will supply a built-in section definition for Appsody.  Once supported, Appsody may be updated to register a 
dynamic section definition.  

This is the built-in appsody section definition that will be added to kAppNav: 

```
kind: ConfigMap
name: kappnav-config
data: 
   sections: | 
       [ { 
           "name": "appsody", 
           "title": "Appsody Information",
           "title.nls": "section.appsody.title",
           "description": "Information about this resource injected by Appsody technology during development and deployment."
           "description": "section.appsody.description", 
           "datasource": "appsody-labels",
           "kinds": ["Deployment","Service"],
           "enablement-label": "dev.appsody.application"
         }
       ]
   section-datasources: | 
       [ { 
           "name": "appsody-labels", 
           "type": "labels",
           "prefixes: [ "org.opencontainer", "dev.appsody" ]
           "labels": []
         }
       ]
```

## Action Enablement 


kAppNav will supply built-in action definitions for Appsody.  Once supported, Appsody may be updated to register a 
dynamic action definitions.    

Thee following action definitions are the built-ins that will be added to kAppNav.  Note the complete list of actions 
and the resources to which they apply is still being defined.


```
apiVersion: v1
kind: ConfigMap
metadata:
  name: kappnav.actions.deployment
  namespace: kappnav
data:
  url-actions: |
    [   
      {
        "name":"appsody-gitrepo",
        "text":"View Source in Git Repo",
        "description":"View source code in git repo",
        "url-pattern":"${resource.$.metadata.labels['org.opencontainers.image.url']}",
        "open-window": "tab",
        "enablement-label":"dev.appsody.application"
      }
    ]
```
