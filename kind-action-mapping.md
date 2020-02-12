# Kind-Action Mapping

Since the beginning, {k}kAppNav has had a builtin mapping scheme to map resource kind to action config maps.  This was done by convention, as described 
in [Action Config Map Naming Convention Design](https://github.com/kappnav/design/blob/master/actions-config-maps.md#action-config-map-naming-convention).

While that is sufficient for core kinds and a small number of custom resource definitions (CRDs), it is not sufficient to
support the growing number of resource kinds emerging on the Kubernetes platform.  A trivial example demonstrates this is true:

There now exists these two Service kinds:

1. v1/Service (core kind)
1. knative.k8s.io.Service (knative kind)

The existing mapping convention is based on the unqualified, kind singular name, which in this example is simply "Service".  
So both Service kinds, above, map to the same action config map, namely:  kappnav.actions.Service.

As the goal is to have independently deployable - and discrete - actions per distinct kind, this mapping is insufficient. 

To remedy the inadequacy of the existing mapping convention approach, we will introduce configuration to specify the mappings explicitly. This configuration will be modelled as a custom resource definition in keeping with the "independently deployable" principle.

## KindActionMapping Custom Resource Definition

The KindActionMapping CRD defines which config maps contain the action definitions for which resource kinds.  The mappings are based on the following resource fields: 

- apiVersion is the group/version identifier of the resource.  Note Kubernetes resources with no group value (e.g. Service) specify apiVersion as version only.  E.g. apiVersion: v1.   
- kind is the resource's kind field
- subkind is the resource's metadata.annotations.kappnav.subkind annotation. See [annotations](https://github.com/kappnav/design/blob/master/annotations.md) for more details.  Note, in practice, we use the subkind annotation only on Deployment and StatefulSet resource kinds. 
- name is the resource's metadata.name field

KindActionMappings provide mapping rules that map a resource to a set of action config maps.  These action config maps are then combined to form the set of actions applicable to the resource.  See [action set determination](#action-set-determination) for further details about how these action config maps are combined. 

**KindActionMapping CRD**

```
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: kindactionmappings.actions.kappnav.io
spec:
  group: actions.kappnav.io
  names:
    kind: KindActionMapping
    plural: kindactionmappings
    singular: kindactionmapping
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
                   apiVersion:
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
| mappings[].apiVersion   | Specifies apiVersion value for a kind-to-configmap mapping. Specified in the form group\/version. The version portion can be wildcarded with \'* \'.  |  
| mappings[].kind    | Specifies kind value for a kind-to-configmap mapping. Can be either a resource kind name or '\*', which means any kind name.|
| mappings[].subkind | Specifies subkind value for a kind-to-configmap mapping. Can be either a resource subkind name or '\*', which means any kind name. Subkind is a {k}AppNav concept that allows any resource kind to be further qualified. It is specified by annotation 'kappnav.subkind'.|
| mappings[].name    | Specifies name value for a kind-to-configmap mapping. Can be either a resource name or '\*', which means any name.|
| mappings[].mapname | Specifies the action configmap name to which the resource is mapped.  The mapname is the resource name of a configmap.  The symbols ${group}, ${kind}, ${subkind}, and ${name} can specified in the mapme value to be substituted at time of use with the matching resource's group, kind, subkind, or name value, respectively. |


## Action Set Determination 

{k}AppNav determines the set of actions for a resource through a process of [mapping](#resource-to-action-configmap-mapping), [lookup](#action-configmap-lookup), and [merge](#action-configmap-merge) to produce the complete set. The mapping conforms to a particular hierarchy, ordered by precedence. 

### Configmap Hierarchy and Precedence 

One or more action configmaps may exist to which the same resource maps.  Multiple distinct action configmaps may exist for any resource instance and are processed in this order, from most specific to least specific:  

For a resource kind qualified by the subkind annotation: 

- kind-subkind.name - instance specific
- kind-subkind - subkind specific
- kind - kind specific

For a resource without subkind qualification: 

- kind.name - instance specific
- kind - kind specific

Multiple KindActionMapping resources may specify mappings for the same resource kind.  When this happens, additional action configmap mappings are inserted into the configmap hierarchy, based on the KindActionMapping instance's precedence value.
 

### Resource to Action Configmap Mapping

To determine the action set for a given resource, the first step is mapping.  The resource's apiVersion, kind, subkind (if specified), and name are used to find matching mappings across all KindActionMapping resources.

The KindActionMappings are processed in descending precedence order with level of specificity - i.e. numerically highest precendence value to lowest within the same level of specificity, meaning instance level first, followed by less specific levels, such as kind. Note subkind is considered more specific than kind alone. 

KindActionMappings resources with the same precedence value are processed together in arbitrary order.  

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
   - apiVersion: extensions/v1beta1
     kind: Deployment
     subkind: Liberty
     mapname: appsody.actions.deployment-liberty
   - apiVersion: extensions/v1beta1
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

Observations: 

1. kappnav.actions.deployment.trader is first in the hierarchy because it is more specific (instance specific) than all the other action configmaps. 
1. appsody.actions.deployment-liberty is ahead of kappnav.actions.deployment-liberty in the hierarchy because it came from a KindActionMapping resource ('appsody') with numerically higher precedence than the other KindActionMapping resource ('default') for that same level of specificity (i.e. subkind level). 

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

   - apiVersion: */*
     name: * 
     subkind: * 
     kind: *
     mapname: ${namespace}.actions.${kind}-${subkind}.${name} 
          
   - apiVersion: */*
     subkind: * 
     kind: *
     mapname: kappnav.actions.${kind}-${subkind} 

   - apiVersion: */*
     name: * 
     kind: *
     mapname: ${namespace}.actions.${kind}.${name}   

   - apiVersion: */*
     kind: *
     mapname: kappnav.actions.${kind}
```

### Implementation Details - Mapping High Level Logic and Example 

Starting with: 

```
apiVersion: extensions/v1beta1
kind: Deployment
metadata: 
  name: trader 
  namespace: stocktrader 
  annotations: 
    kappnav.subkind: Liberty 
```

and KindActionMappings [default KindActionMapping](https://github.com/kappnav/design/blob/master/kind-action-mapping.md#pre-defined-kindactionmapping-custom-resource) and 

```
apiVersion: actions.kappnav.io/v1beta1
kind: KindActionMapping
metadata:
  name: appsody
  namespace: appsody
spec:
   precedence: 2
   mappings:
   - apiVersion: extensions/v1beta1
     kind: Deployment
     subkind: Liberty
     mapname: appsody.actions.deployment-liberty
   - apiVersion: extensions/v1beta1
     kind: Deployment
     mapname: appsody.actions.deployment
```

First gather the inputs to the mapping determination from the subject resource: 

1. apiVersion = extensions/v1beta1
1. name= trader
1. kind= Deployment
1. subkind= Liberty 

Because the resource has subkind, the target hierarchy structure is: 

- kind-subkind.name - instance specific
- kind-subkind - subkind specific
- kind - kind specific

Note if there was no subkind specified, the target hierarchy structure would be: 

- kind.name - instance specific
- kind - kind specific 

The KindActionMappings CRs are examined in order of precedence, in descending order - e.g. 9, then 8, etc, based on whatever the highest precedence number is among the existent KindActionMappings CRs.

The mappings section in each KindActionMappings is examined to build the candidate hierarchy list by matching against the individual mappings in each KindActionMapping, searching for matches from most specific to least specific, according to the applicable target hierarcy.  For this example, that is: 

- kind-subkind.name - instance specific
- kind-subkind - subkind specific
- kind - kind specific

So the mappings in the appsody KindActionMapping (highest precedence) are examined: 

- 1st for exact match on (name, subkind, kind)
- 2nd for wildcard match on (name, subkind, kind)

- 3rd for exact match on (subkind, kind)
- 4th for wildcard match on (subkind, kind)

- 5th for exact match on (kind)
- 6th for wildcard match on (kind)

Yielding candidate configmap names: 

- appsody.actions.deployment-liberty
- appsody.actions.deployment 

The default KindActionMapping is examined next (and last, since there are no more KindActionMapping CRs) the same way, yielding: 

- stocktrader.actions.deployment-liberty.trader
- kappnav.actions.deployment-liberty
- kappnav.actions.deployment 

Combined by hierarchy level and precedence order, we have final candidate list: 

- stocktrader.actions.deployment-liberty.trader (instance specific, precedence 1)
- appsody.actions.deployment-liberty (subkind specific, precedence 2)
- kappnav.actions.deployment-liberty (subkind specific, precedence 1)
- appsody.actions.deployment (kind specific, precedence 2)
- kappnav.actions.deployment (kind specific, precedence 1)

Next, these names are used to search for actual configmap resources; those found are combined to yield the effective hierarchy. For this example, let's imagine the existent configmaps found are: 

- stocktrader.actions.deployment-liberty.trader in stock-trader namespace
- appsody.actions.deployment in appsody namespace 
- kappnav.actions.deployment in kappnav namespace

Existing API code already exists to merge the effective hiearchy.  
