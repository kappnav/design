# Kind-Action Mapping

Since the beginning, {k}kAppNav has had a builtin mapping scheme to map resource kind to action config maps.  This was done by naming convention, as described 
in [Action Config Map Naming Convention Design](https://github.com/kappnav/design/blob/master/actions-config-maps.md#action-config-map-naming-convention).

While that is sufficient for core kinds and a small number of custom resource definitions (CRDs), it is not sufficient to
support the growing number of resource kinds emerging on the Kubernetes platform.  A trivial example demonstrates this is true:

There now exists these two Service kinds:

1. v1/Service (core kind)
1. knative.k8s.io.Service (knative kind)

The existing mapping convention is based on the unqualified, singular kind name, which in this example is simply "Service".  
So both Service kinds, above, map to the same action config map, namely:  kappnav.actions.Service.

As the goal is to have discrete and independently deployable actions per distinct kind, this mapping is insufficient. 

To remedy the limitation of the existing mapping convention approach, we will introduce configuration to specify the mappings explicitly. This configuration will be modelled as a custom resource definition in keeping with the "independently deployable" principle.

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
                   name: 
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
| mappings[].apiVersion   | Specifies apiVersion value for a kind-to-configmap mapping. Specified in the form group\/version or version only, for kinds that have no group name. The group and version values can be wildcarded with \'* \'.  |  
| mappings[].kind    | Specifies kind value for a kind-to-configmap mapping. Can be either a resource kind name or '\*', which means any kind name.|
| mappings[].subkind | Specifies subkind value for a kind-to-configmap mapping. Can be either a resource subkind name or '\*', which means any kind name. Subkind is a {k}AppNav concept that allows any resource kind to be further qualified. It is specified by annotation 'kappnav.subkind'.|
| mappings[].name    | Specifies name value for a kind-to-configmap mapping. Can be either a resource name or '\*', which means any name.|
| mappings[].mapname | Specifies the action configmap name to which the resource is mapped.  The mapname is the resource name of a configmap.  The symbols ${namespace}, ${kind}, ${subkind}, and ${name} can specified in the mapname value to be substituted at time of use with the matching resource's namespace, kind, subkind, or name value, respectively. |


## Action Set Determination 

{k}AppNav determines the set of actions for a resource through a process of [mapping](#resource-to-action-configmap-mapping), [lookup](#action-configmap-lookup), and [merge](#action-configmap-merge) to produce the complete set. The mapping conforms to a particular hierarchy, ordered by precedence. 

### Configmap Hierarchy and Precedence 

One or more action configmaps may exist to which the same resource maps. Multiple mapping rules may exist to which a resource maps; mapping rules are searched for in this order, using the match values from the from resource, searching for a matching rule from the most specific to least specific:  

For a resource kind qualified by the subkind annotation: 

- kind-subkind.name - instance specific 
- kind-subkind - subkind specific
- kind - kind specific

For a resource without subkind qualification: 

- kind.name - instance specific
- kind - kind specific

Multiple KindActionMapping resources may specify mappings rules for the same resource kind.  When this happens, additional action configmap mappings are inserted into the configmap hierarchy, based on the KindActionMapping instance's precedence value.
 

### Resource to Action Configmap Mapping

To determine the action set for a given resource, the first step is mapping.  The resource's apiVersion, kind, subkind (if specified), and name are used to find matching mapping rules across all KindActionMapping CRs.

The KindActionMappings are processed in descending precedence order with level of specificity - i.e. numerically highest precendence value to lowest. 

The individual mapping rules within a KindActionMapping instance are processed in order from first to last, searching for the first matching rule for a given level of specifity (i.e. instance specific, subkind specific, etc). Only mappings that specify the same set of fields based on the current level of specificity being searched is eligible for match consideration. I.e.

- When searching for instance specific (with subkind), only mappings containing {apiVersion, name, subkind, kind} are considered. 
- When searching for instance specific (without subkind), only mappings containing {apiVersion, name, kind} are considered.
- When searching for subkind specific, only mappings containing {apiVersion, subkind, kind} are considered. 
- When searching for kind specific, only mappings that specify {apiVersion, kind} are considered.

KindActionMappings resources with the same precedence value are processed together in arbitrary order.  

### apiVersion Matching 

The apiVersion in a mapping can be either group/version or version alone.  A resource's apiVersion is matched against the apiVersion value in a mapping rule according to whether or not it specifies group/version or version alone.  E.g.

1. If a resource's apiVersion specifies group/version, it can ony match mapping rules that specify an apiVerson in the form 'group/version', including wildcards variants, e.g. 'group/*' 

2. If a resource's apiVersion specifies version only, it can ony match mapping rules that specify an apiVerson in the form 'version', including the wildcards variant, '*' 

### Action Configmap Lookup 

After the set of potential configmap names are determined and placed in hierarchy order, the actual configmaps are looked up by name to produce the effective hierarchy.  

### Namespaces 

Instance specific configmaps are searched for in the resource's namespace.  All other configmaps are searched for in the same namespace as the KindActionMapping resource.


### Action Configmap Merge 

The merge behavior is not new.  It was defined in the original [action support](https://github.com/kappnav/design/blob/master/actions-config-maps.md). 

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

1. - apiVersion: */*
     name: * 
     subkind: * 
     kind: *
     mapname: ${namespace}.actions.${kind}-${subkind}.${name} 
         
2. - apiVersion: */*
     subkind: * 
     kind: *
     mapname: kappnav.actions.${kind}-${subkind} 

3. - apiVersion: */*
     name: * 
     kind: *
     mapname: ${namespace}.actions.${kind}.${name}   

4. - apiVersion: */*
     kind: *
     mapname: kappnav.actions.${kind}
     
5. - apiVersion: *
     name: * 
     subkind: * 
     kind: *
     mapname: ${namespace}.actions.${kind}-${subkind}.${name} 
          
6. - apiVersion: *
     subkind: * 
     kind: *
     mapname: kappnav.actions.${kind}-${subkind} 

7. - apiVersion: *
     name: * 
     kind: *
     mapname: ${namespace}.actions.${kind}.${name}   

8. - apiVersion: *
     kind: *
     mapname: kappnav.actions.${kind}
```

### Mapping High Level Logic and Examples 


#### extensions/v1beta1 Deployment                                                                                                                                                                                                                                                    
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
1. - apiVersion: extensions/v1beta1 
     kind: Deployment
     subkind: Liberty
     mapname: appsody.actions.deployment-liberty
2. - apiVersion: extensions/v1beta1
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

The KindActionMappings CRs are examined in order of precedence, in descending order - e.g. 2, then 1, etc, based on whatever the highest precedence number is among the existent KindActionMappings CRs.           

The mappings section in each KindActionMappings is examined in order from first to last searching for matching rules in order to build the candidate hierarchy list by matching against the individual mappings in each KindActionMapping, searching for matches from most specific to least specific, according to the applicable target hierarcy.  For this example, that is: 

- kind-subkind.name - instance specific
- kind-subkind - subkind specific
- kind - kind specific

So the mappings in the appsody KindActionMapping (highest precedence) are examined for match, according to candidate hierarchy list:

- 1st for match on {apiVersion, name, subkind, kind} -> no match found

- 2nd for match on {apiVersion, subkind, kind} -> match found (rule 1)

- 3rd for match on (apiVersion, kind) -> match found (rule 2) 

Yielding candidate configmap names: 

- appsody.actions.deployment-liberty
- appsody.actions.deployment 

The default KindActionMapping is examined next (and last, since there are no more KindActionMapping CRs) the same way: 

- 1st for match on (apiVersion, name, subkind, kind) -> match found (rule 1)

- 2nd for match on (apiVersion, subkind, kind) -> match found (rule 2) 

- 3rd for match on (apiVersion, kind) -> match found (rule 4)

yielding: 

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

#### v1 Service 
                                                                                                                              
Starting with: 

```
apiVersion: v1
kind: Service
metadata: 
  name: trader 
  namespace: stocktrader 

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
1. - apiVersion: v1
     kind: Service
     mapname: appsody.actions.service
```

First gather the inputs to the mapping determination from the subject resource: 

1. apiVersion = v1
1. name= trader
1. kind= Service

Because the resource does not have subkind, the target hierarchy structure is: 

- kind-subkind.name - instance specific
- kind - kind specific

Note if subkind was specified, the target hierarchy structure would be: 

- kind.name - instance specific
- kind-subkind - subkind specific
- kind - kind specific 

The KindActionMappings CRs are examined in order of precedence, in descending order - e.g. 2, then 1, etc, based on whatever the highest precedence number is among the existent KindActionMappings CRs.     

The mappings section in each KindActionMappings is examined from first to last searching for matching rules in order to build the candidate hierarchy list by matching against the individual mappings in each KindActionMapping, searching for matches from most specific to least specific, according to the applicable target hierarcy.  For this example, that is: 

- kind-subkind.name - instance specific
- kind - kind specific

So the mappings in the appsody KindActionMapping (highest precedence) are examined: 

- 1st for match on {apiVersion, name, kind} -> no match found

- 2nd for match on (apiVersion, kind) -> match found (rule 1) 

Yielding candidate configmap name: 

- appsody.actions.service

The default KindActionMapping is examined next (and last, since there are no more KindActionMapping CRs) the same way: 

- 1st for match on (apiVersion, name, kind) -> match found (rule 7)

- 2nd for match on (apiVersion, kind) -> match found (rule 8)

yielding: 

- stocktrader.actions.service.trader
- kappnav.actions.service

Combined by hierarchy level and precedence order, we have final candidate list: 

- stocktrader.actions.service.trader (instance specific, precedence 1)
- appsody.actions.service (kind specific, precedence 2)
- kappnav.actions.service (kind specific, precedence 1)

Next, these names are used to search for actual configmap resources; those found are combined to yield the effective hierarchy. For this example, let's imagine the existent configmaps found are: 

- stocktrader.actions.service.trader in stock-trader namespace
- appsody.actions.service in appsody namespace 
- kappnav.actions.service in kappnav namespace

Existing API code already exists to merge the effective hiearchy.                                                                                                          
