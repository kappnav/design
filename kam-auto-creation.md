# Kind Action Mapping (KAM) Auto Creation

When an operator installs its action/status/section config maps (hereafter referred to herein as simply "config maps") and KAM before application navigator is installed, the KAM cannot be created because the KAM CRD does not yet exist.  With the KAM auto creation, when Application Navigator is installed and started, it will create the kams automatically.

## Embedded KAM in Action Config Map
Application Navigator will auto-create/delete a kam resource when a specially labeled action/status/detail config map is created. 

When an action/status/detail config map is created that contains the following label and data, the controller will create the kam resource specified automatically:
```

apiVersion: v1
kind: ConfigMap
metadata: 
  name: kappnav.actions|status-mapping|sections.{kind}[-subkind][.name]
  namespace: test
  labels: 
    kappnav.io/map-type: actions | status | sections 
    annotations: 
      kappnav.actions.on.conflict: "merge" | "replace" 
data:
  kam-defs: | 
    {
      "apiVersion": "actions.kappnav.io/v1",
      "kind": "KindActionMapping",
      "metadata": {
        "name": "emkam",
      },
      "spec": {
        "precedence": 3,
        "mappings": [
          {
            "apiVersion": "apps/v1",,
            "kind": "Deployment",
            "name": "test",
            "mapname": "kappnav.actions.testmap"
          }
        ],
        "statusMappings": [
          {
            "apiVersion": "apps/v1",,
            "kind": "Deployment",
            "name": "test",
            "mapname": "kappnav.status-mapping.testmap"
          }
        ],
        "sectionMappings": [
          {
            "apiVersion": "apps/v1",,
            "kind": "Deployment",
            "name": "test",
            "mapname": "kappnav.sections.testmap"
          }
        ]
      }
    } 
  
Would produce:
  
apiVersion: actions.kappnav.io/v1
kind: KindActionMapping
metadata:
  creationTimestamp: 2020-06-23T22:44:21Z
  generation: 3
  labels:
    kappnav.kam.auto-created: "true"
  name: emkam
  namespace: test
  resourceVersion: "89718478"
  selfLink: /apis/actions.kappnav.io/v1/namespaces/test/kindactionmappings/emkam
  uid: 6bd8bf7d-16c9-475a-9a3b-7be37355df07
spec:
  mappings:
  - apiVersion: apps/v1
    kind: Deployment
    mapname: kappnav.actions.testmap
    name: test
  precedence: 3
  sectionMappings:
  - apiVersion: apps/v1
    kind: Deployment
    mapname: kappnav.sections.testmap
    name: test
  statusMappings:
  - apiVersion: apps/v1
    kind: Deployment
    mapname: kappnav.status-mapping.testmap
    name: test
```
The KAM is installed in the same namespace as the one that the associated configmap resides.

The owner of the configmap also owns the kam embeded.


## KAM Lifecycle Automation
When app navigator comes up, it automatically creates a KAM CR defined in a config map with the "kappnav.io/map-type" label.  It will find all of the pre-existing kam definitions in the configmaps and performs the kam creations when app navigator starts.

Once an app nav controller starts up, it must sync config maps with kams for the following main events:
1. when config map created, create kam
1. when config map updated, update kam
1. when config map deleted, delete kam
