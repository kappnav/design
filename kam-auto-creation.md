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
          "precedence": <precdence>,
          "mappings": [
            {
                "apiVersion": "<apiversion>",
                "owner": {
                    "apiVersion": "<owner-apiversion",
                    "kind": "<owner-kind",
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
                    "apiVersion": "<owner-apiversion",
                    "kind": "<owner-kind",
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
                    "apiVersion": "<owner-apiversion",
                    "kind": "<owner-kind",
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
