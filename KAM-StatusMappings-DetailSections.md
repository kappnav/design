# Extend KAM to Status Mappings and Detail Sections

The application and component status and UI detail sections are configured with ConfigMaps. The KAM schemes of mapping resouce kind to status config maps or detail section config maps are mostly the same as the one for the KAM mapping scheme to map resource kind to action configmaps described in [Kind-Action Mapping](https://github.com/kappnav/design/blob/master/actions-config-maps.md) and with some differences, which are described in this document. With the new mapping scheme, a status config map or detail section config map can exist outside kappnav namespace.

## New Additions to the KAM Custom Resource Definition
Addtional mapping rules that map a resouce to a status config map or a set of detail section configmap are provided to the existing KAM custom resouce defintion as below:
```
mappings:
  ...
statusMappings:
  type: array
  items: 
    type: object 
    properties: 
      apiVersion:
        type: string 
      owner:
        properties:
          kind:
            type: string
          apiVersion:
            type: string
          uid:
            type: string
        type: object 
      kind: 
        type: string   
      mapname: 
        type: string       

detailsMappings:
  type: array
  items: 
    type: object 
    properties: 
      apiVersion:
        type: string 
      owner:
        properties:
          kind:
            type: string
          apiVersion:
            type: string
          uid:
            type: string
        type: object 
      kind: 
        type: string
      name: 
        type: string
      mapname: 
        type: string 
```
## Config Map Set Determination
{k}AppNav uses the same mapping rules decribed in the KAM design doc to determines the set of status or detail section config maps for a resource through the same process of mapping, lookup, and merge if applies to produce the complete set. The mapping conforms to a particular hierarchy, ordered by precedence.

### Configmap Hierarchy and Precedence

#### Status Mappings
Only support the kind specific case as the status mapping config map has no named and subkind elements.

#### Detail Sections
One or more detail section configmaps may exist to which the same resource maps. Multiple mapping rules may exist to which a resource maps; mapping rules are searched for in this order, using the match values from the from resource, searching for a matching rule from the most specific to least specific:

    kind.name - instance specific
    kind - kind specific

The KAM precedence rule applies to both status mapping and detail sections cases.

### Merge Considerations
* Status mapping: it has no the elements for "name" and "subkind" so merge does not applies to it. 
* Detail sections: could merge, but do it as when there is a need for it.
* Resources with the same precedence value are processed together in arbitrary order applies

## Related design document links:
* [Kind-Action Mapping](https://github.com/kappnav/design/blob/master/actions-config-maps.md)
* [Application and Component Status](https://github.com/kappnav/design/blob/master/status-determination.md)
* [UI Detail Sections](https://github.com/kappnav/design/blob/master/ui-detail-sections.md)
