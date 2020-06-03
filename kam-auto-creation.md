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

## KAM LifeCycle Automation
When app nav comes up, it auto-creates an Application CR for that Deployment "so the user defined kam is installed during a kappnav install?" Yes, essentially it's created by the appnav operator anytime a config map is created with the kappnav-kam (however we spell it) label. That includes finding all of the pre-existing ones when app navigator operator starts,  appnav operator does this for application already so we just need to parallel the existing support that does auto-create for application CR and do same for config maps that have kam label.

Main events:
on app nav controller start up - must sync config maps with kams
1. when config map created, create kam
1. when config map updated, update kam
1. when config map deleted, delete kam
