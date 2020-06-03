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
  kappnav.io/map-type: action | status | sections 
  annotations: 
     kappnav.actions.on.conflict: "merge" | "replace" 
data:
  kam-defs: | 
      [
        "metadata": {
          "name": "<kam-name>",
        },
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
        }
      ], 
      
```
The KAM is installed in the same namespace as the one that the associated configmap resides.

The owner of the configmap also owns the kam embeded.

Questions:
1. With onwer info, if we making the confimap itself the owner of the KAM, should the KAM definition need to include the owner info?
CPV: no. The configmap can be the owner of the kam - that would go in the ownerRef section of the kam.  But the owner def inside the kam mapping itself is not for that; if it exists, it is user provided and is used to qualify the mapping of a resource to a map name, as specified in the kam spec. 

## KAM Lifecycle Automation
When app navigator comes up, it automatically creates a KAM CR defined in a config map is created with the "kappnav.kam.auto-create" label.  It will find all of the pre-existing kam definitions in the configmaps and performs the kam creations when app navigator operator starts.

Once an app nav controller starts up, it must sync config maps with kams for the following main events:
1. when config map created, create kam
1. when config map updated, update kam
1. when config map deleted, delete kam

Questions:
the kam creation is done by the kappnav operator during the installation and the kam creation/update/deletion is performed by the kappna controller?
