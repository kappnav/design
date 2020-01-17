# Kind-Action Mapping

Since the beginning {k}kAppNav introduced a builtin mapping scheme to map resource kind to action config maps.  This was done by convention, as 
in [Action Config Map Naming Convention Design](https://github.com/kappnav/design/blob/master/actions-config-maps.md#action-config-map-naming-convention).

While that was sufficient for core kinds and a small number of custom resource definitions (CRDs), it is not sufficient to
support the growing number of resource kinds emerging on the Kubernetes platform.  A trivial example demonstrates this is true:

There now exists these two Service kinds:

1. v1/Service (core kind)
1. knative.k8s.io.Service (knative kind)

The existing mapping convention is based on the unqualified, kind singular name, which in this example is simply "Service".  
So both Service kinds, above, map to the same action config map, namely:  kappnav.actions.Service.

As the goal is to have independently deployable - and discrete - actions per distinct kind, this mapping is insufficient. 

To remedy the inadequacy of the mapping convention approach, we will introduce configuration to specify the mappings explicitly. This configuration will be modelled as a custom resource definition in keeping with the "independently deployable" principle.

## KindActionMapping Custom Resource Definition

The KindActionMapping CRD defines which config maps contain the action definitions for which resource kinds.  The mappings are based on the following resource fields: 

- group is the group portion of the resource's apiVersion field (i.e. group/version) 
- kind is the resource's kind field
- subkind is the resource's metadata.annotations.kappnav.subkind annotation. See [annotations](https://github.com/kappnav/design/blob/master/annotations.md) for more details.
- name is the resource's metadata.name field

KindActionMappings provide mapping rules that map a resource to a set of action config maps.  These action config maps are then combined to form the set of actions applicable to the resource.  See [next section](#action-set-determination) for further details about how these action config maps are combined together. 

**KindActionMapping CRD**

```
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: kindactionsmappings.kappnav.io
spec:
  group: actions.kappnav.io
  names:
    kind: KindActionMapping
    plural: kindactionsmappings
    singular: kindactionsmapping
  scope: Namespaced
  validation:
    openAPIV3Schema:
      properties:
        apiVersion:
          type: string
        kind:
          type: string
        metadata:
          type: object
        spec:
          type: object
          properties:
            precedence:
              type: integer
            mappings:
              type: array
              items: 
                 type: object 
                 properties: 
                   group:
                     type: string 
                   kind: 
                     type: string 
                   subkind: 
                     type: string 
                   mapname: 
                     type: string 

  version: v1beta1
```

Where the spec fields are: 

| Field          | Description                      |
|----------------|----------------------------------|
| precedence     | Specifies natural number (1-9) precedence value for mappings defined by this KindActionMapping instance. A higher number means higher precedence.  The default is 1.  |
| mappings       | Specifies a set (array) of "kind-to-configmap mappings". | 
| mappings[].group   | Specifies group value for a kind-to-configmap mapping. Can be either a resource group name or '\*', which means any group name. The group name 'core' is used to designate those Kubernetes kinds that have no group name - e.g. Service |  
| mappings[].kind    | Specifies kind value for a kind-to-configmap mapping. Can be either a resource kind name or '\*', which means any kind name.|
| mappings[].subkind | Specifies subkind value for a kind-to-configmap mapping. Can be either a resource subkind name or '\*', which means any kind name. Subkind is a {k}AppNav concept that allows any resource kind to be further qualified. It is specified by annotation 'kappnav.subkind'.|
| mappings[].name    | Specifies name value for a kind-to-configmap mapping. Can be either a resource name or '\*', which means any name.|
| mappings[].mapname | Specifies the action configmap name to which the resource is mapped.  The mapname is the resource name of a configmap.  The symbols ${group}, ${kind}, ${subkind}, and ${name} can specified in the mapname value to be substituted at time of use with the matching resource's group, kind, subkind, or name value, respectively. |


## Action Set Determination 

{k}AppNav determines the set of actions for a resource through a process of [mapping](#resource-to-action-configmap-mapping), [lookup](#action-configmap-lookup), and [merge](#action-configmap-merge) to produce the complete set. The mapping conforms to a particular hierarchy, ordered by precedence. 

### Configmap Hierarchy and Precedence 

One or more action configmaps may exist to which the same resource maps.  Multiple distinct action configmaps may exist for any resource instance and are processed in this order, from most specific to least specific:  

For a resource kind qualified by the subkind annotation: 

- kind-subkind.name - instance specific
- kind-subkind - specific
- kind - specific

For a resource without subkind qualification: 

- kind.name - instance specific
- kind - specific

Multiple KindActionMapping resources may specify mappings for the same resource kind.  When this happens, additional action configmap mappings are inserted into the configmap hierarchy, based on the KindActionMapping instance's precedence value.

e.g. 

Given resource of kind Deployment with name trader in stocktrader namespace and these KindActionMappings: 

- A KindActionMapping resource named 'default' in kappnav namespace with precedence 1 (default) 
- A KindActionMapping resource named 'appsody' in appsody namespace with precedence 2

that when processed for the trader Deployment resource with subkind 'Liberty' yield these configmap names, respectively: 

from KindActionMapping resource 'default': 

- stocktrader.actions.deployment-liberty.trader
- kappnav.actions.deployment-liberty
- kappnav.actions.deployment 

from KindActionMapping resource 'appsody': 

- appsody.actions.deployment-liberty
- appsody.actions.deployment 

Then the candidate hierarchy for this resource would be in order of precedence (highest first) within order of specificity: 

- stocktrader.actions.deployment-liberty.trader (instance specific, precedence 1)
- appsody.actions.deployment-liberty (subkind specific, precedence 2)
- kappnav.actions.deployment-liberty (subkind specific, precedence 1)
- appsody.actions.deployment (kind specific, precedence 2)
- kappnav.actions.deployment (kind specific, precedence 1)


Observations: 

1. kappnav.actions.deployment.trader is first in the hierarchy because it is more specific (instance specific) than all the other action configmaps. 
1. appsody.actions.deployment-liberty is ahead of kappnav.actions.deployment-liberty in the hierarchy because it came from a KindActionMapping resource ('appsody') with numerically higher precedence than the other KindActionMapping resource ('default') for that same level of specificity (i.e. subkind level).  

### Resource to Action Configmap Mapping

To determine the action set for a given resource, the first step is mapping.  The resource's group, kind, subkind (if applicable), and name are used to find matching mappings across all KindActionMapping resources.

The KindActionMappings are processed in descending precedence order - i.e. numerically highest precendence value to lowest. KindActionMappings resources with the same precedence value are processed together in arbitrary order.  

e.g. consider resource:

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata: 
  name: trader 
  namespace: stocktrader 
  annotations: 
    kappnav.subkind: Liberty 
```

and this KindActionMapping: 

```
apiVersion: actions.kappnav.io/v1beta1
kind: KindActionMapping
metadata:
  name: appsody
  namespace: appsody
spec:
   precedence: 2
   mappings:
   - group: v1
     kind: Deployment
     subkind: Liberty
     mapname: appsody.actions.deployment-liberty
   - group: v1
     kind: Deployment
     mapname: appsody.actions.deployment
```

and the [default KindActionMapping](#pre-defined-kindactionmapping-custom-resource).

After processing the 'appsody' KindActionMapping resource, the following configmap names are determined: 

- appsody.actions.deployment-liberty
- appsody.actions.deployment 

After processing the 'default' KindActionMapping resource, the following configmap names are determined: 

- stocktrader.actions.deployment-liberty.trader
- kappnav.actions.deployment-liberty
- kappnav.actions.deployment 

The candidate hierarchy of configmap names, in order of precedence is: 

- stocktrader.actions.deployment-liberty.trader (instance specific, precedence 1)
- appsody.actions.deployment-liberty (subkind specific, precedence 2)
- kappnav.actions.deployment-liberty (subkind specific, precedence 1)
- appsody.actions.deployment (kind specific, precedence 2)
- kappnav.actions.deployment (kind specific, precedence 1)

### Action Configmap Lookup 

After the set of potential configmap names are determined and placed in hierarchy order by mapping, the actual configmaps are looked up by name to produce the effective hierarchy.  

**Namespace Rule** 

Instance specific configmaps are searched for in the resource's namespace.  All other configmaps are searched for in the same namespace as the KindActionMapping resource.

E.g. 

If the following action configmaps were found, yielding the effective hierarchy: 

- stocktrader.actions.deployment-liberty.trader in stock-trader namespace
- appsody.actions.deployment in appsody namespace 
- kappnav.actions.deployment in kappnav namespace

They would be processed in that order to produce the merged, final action set. 

### Action Configmap Merge 

The action configmaps found are processed in order of precedence and merged together.  They are read and processed one by one, according to the effective hierarchy order. Each action configmap specifies either to 'merge' or 'replace'. If the action configmap specifies 'replace', no further action configmaps in the hierarchy are processed.  If the action configmap specifies 'merge', the actions it defines are combined with the actions defined by further action configmaps from the effective hierarchy. If two actions of the same type (e.g. url-action) have the same name, the first one found takes precedence, effectively overriding all others of the same name. 

e.g. 

If the following action configmaps have the specified replace/merge policies and the indicated action definitions: 

- stocktrader.actions.deployment-liberty.trader in stock-trader namespace, policy=merge
   - action name 'klog'
- appsody.actions.deployment in appsody namespace, policy=replace
   - action name 'klog'
   - action name 'appsody-action'
- kappnav.actions.deployment in kappnav namespace, policy=merge 

Then only these action config maps would contribute actions to the final action set: 

- stocktrader.actions.deployment-liberty.trader in stock-trader namespace, policy=merge
- appsody.actions.deployment in appsody namespace, policy=replace

Note: kappnav.actions.deployment is ignored because of the policy=replace from appsody.actions.deployment config map.

And the final action set would be: 

1. 'klog' from stocktrader.actions.deployment-liberty.trader
1. 'appsody-action' from appsody.actions.deployment

## Pre-defined KindActionMapping Custom Resource 

```
apiVersion: actions.kappnav.io/v1beta1
kind: KindActionMapping
metadata:
  name: default
  namespace: kappnav
spec:
   precedence: 1 
   mappings:
   - group: app.k8s.io
     kind: Application
     name: * 
     mapname: application.actions.${name}
   - group: app.k8s.io
     kind: Application
     mapname: kappnav.actions.application
   - group: core
     kind: *
     subkind: * 
     name: * 
     mapname: kappnav.actions.${kind}-${subkind}.${name} 
   - group: core
     kind: *
     subkind: * 
     mapname: kappnav.actions.${kind}-${subkind} 
   - group: core
     kind: *
     name: * 
     mapname: kappnav.actions.${kind}.${name}
   - group: core
     kind: *
     mapname: kappnav.actions.${kind}
   - group: extensions 
     kind: *
     mapname: kappnav.actions.${kind}
   - group: extensions
     kind: *
     name: * 
     mapname: kappnav.actions.${kind}.${name} 
   - group: extensions 
     kind: *
     subkind: * 
     mapname: kappnav.actions.${kind}-${subkind}
   - group: extensions
     kind: *
     subkind: * 
     name: * 
     mapname: kappnav.actions.${kind}-${subkind}.${name}
   - group: kappnav.io
     kind: * 
     mapname: kappnav.actions.${kind}
   - group: kappnav.io
     kind: * 
     name: * 
     mapname: kappnav.actions.${kind}.${name} 
   - group: route.openshift.io
     kind: *
     mapname: kappnav.actions.${kind}
   - group: route.openshift.io
     kind: *
     name: * 
     mapname: kappnav.actions.${kind}.${name} 
```
