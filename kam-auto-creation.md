# Kind Action Mapping (KAM) Auto Creation

When an opeator installing its config maps and kams before an application navigator is installed, the kam cannot be created as 
Application Navigator is not installed, therefore, no KAM CRD is available yet. With the KAM auto creation, when Application 
Navigator will create the kams automatically.

## Embeded KAM in Action Config Map
Application Navigator will auto-create/delete a kam resource when a specially labeled onfig map is created. 

When a config map is created that contains the following label and data, the controller will create the kam resource specified automatically:
```
labels: 
    kappnav.kam.auto-create: true | false 

apiVersion: v1
kind: ConfigMap
metadata: 
  name: kappnav.actions.{kind}[-subkind][.name]
  annotations: 
     kappnav.actions.on.conflict: "merge" | "replace" 
data:
  kam-defs: | 
      [
        "spec": {
          "precedence": <precedence>,
          "mappings": [
            {
                "apiVersion": "<apiversion>",
                "owner": {
                    "apiVersion": "v1",
                    "kind": "ConfigMap",
                    "uid": "<owner-uid>"
                }, 
                "kind": "<kind>",
                "subkind": "<subkind>",
                "name": "<name>",
                "mapname": "<mapname>"
            }
          ],          
          "sectionMappings": [
            {
                "apiVersion": "<apiversion>",
                "owner": {
                    "apiVersion": "v1",
                    "kind": "ConfigMap",
                    "uid": "<owner-uid>"
                }, 
                "kind": "<kind>",
                "subkind": "<subkind>",
                "name": "<name>",
                "mapname": "<mapname>"
            }
          ],
          "statusMappings": [
            {
                "apiVersion": "<apiversion>",
                "owner": {
                    "apiVersion": "v1",
                    "kind": "ConfigMap",
                    "uid": "<owner-uid>"
                }, 
                "kind": "<kind>",
                "subkind": "<subkind>",
                "name": "<name>",
                "mapname": "<mapname>"
            }
          ]
        }
      ], 
      
```
Questions:
1. Does the KAM reside the same namespace as the associated configmap or the kam namespace needs to be included here?
1. With onwer info, if we making the confimap itself the owner of the KAM, should the KAM definition need to include the owner info?

## KAM Lifecycle Automation
When app navigator comes up, it automatically creates a KAM CR defined in a config map is created with the "kappnav.kam.auto-create" label.  It will find all of the pre-existing kam definitions in the configmaps and performs the kam creations when app navigator operator starts.

Once an app nav controller starts up, it must sync config maps with kams for the following main events:
1. when config map created, create kam
1. when config map updated, update kam
1. when config map deleted, delete kam
