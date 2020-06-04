# Kind Action Mapping (KAM) Auto Creation

When an operator installs its action/status/section config maps (hereafter referred to herein as simply "config maps") and KAM before application navigator is installed, the KAM cannot be created because the KAM CRD does not yet exist.  With the KAM auto creation, when Application Navigator is installed and started, it will create the kams automatically.

## Embedded KAM in Action Config Map
Application Navigator will auto-create/delete a kam resource when a specially labeled action/status/detail config map is created. 

When an action/status/detail config map is created that contains the following label and data, the controller will create the kam resource specified automatically:
```

apiVersion: v1
kind: ConfigMap
metadata: 
  name: kappnav.actions.{kind}[-subkind][.name]
labels: 
  kappnav.io/map-type: actions | status | sections 
  annotations: 
     kappnav.actions.on.conflict: "merge" | "replace" 
data:
  kam-defs: | 
      [
        "apiVersion": "actions.kappnav.io/v1",
        "kind": "KindActionMapping",
        "metadata": {
          "name": "<kam-name>",
        },
        "spec": {
          "precedence": <precedence>,
          "mappings": [
            {
                "apiVersion": "<apiversion>",
                "owner": {
                    "apiVersion": "<owner-apiVersion>",
                    "kind": "<owner-kind>",
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
                    "apiVersion": "<owner-apiVersion>",
                    "kind": "<owner-kind>",
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
                    "apiVersion": "<owner-apiVersion>",
                    "kind": "<owner-kind>",
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
The KAM is installed in the same namespace as the one that the associated configmap resides.

The owner of the configmap also owns the kam embeded.


## KAM Lifecycle Automation
When app navigator comes up, it automatically creates a KAM CR defined in a config map with the "kappnav.io/map-type" label.  It will find all of the pre-existing kam definitions in the configmaps and performs the kam creations when app navigator starts.

Once an app nav controller starts up, it must sync config maps with kams for the following main events:
1. when config map created, create kam
1. when config map updated, update kam
1. when config map deleted, delete kam
