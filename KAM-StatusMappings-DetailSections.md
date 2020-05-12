# Extend Kind Action Mapping to Status Mappings and Detail Section Mappings

The application and component status and UI detail sections are configured with ConfigMaps, that allows an extension of the Kind Action Mapping (KAM) functionalities.  The KAM schemes of mapping resouce kind to status config maps or detail section config maps are mostly the same as the one for the KAM mapping scheme to map resource kind to action configmaps described in [Kind-Action Mapping](https://github.com/kappnav/design/blob/master/actions-config-maps.md) and with some exceptions, which are described in this document. With the new extension, a status config map or detail section config map can exist outside kappnav namespace.

## New Additions to the KAM Custom Resource Definition
Addtional mapping rules that map a resouce to a status config map or a set of detail section configmap are provided to the existing KAM custom resouce defintion as below. 

Note that 
* there is no "subkind" and "name" property defined for "statusMappings"
* there is no "name" property defined for "detailsMappings"

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
{k}AppNav uses the same mapping rules decribed in the KAM design to determines the set of status or detail section configmaps for a resource through the same process of mapping, lookup, and merge if applies to produce the complete set. The mapping conforms to a particular hierarchy, ordered by precedence.

### Configmap Hierarchy and Precedence

#### Status Mappings
Only support the kind specific case as the status mapping config map has no named and subkind elements.

#### Detail Sections
One or more detail section configmaps may exist to which the same resource kind maps. Multiple mapping rules may exist to which a resource maps. Same mapping and search rules for KAMs applies to this simpler case in which "subkind" element does not exist.

    kind.name - instance specific
    kind - kind specific

The KAM precedence rule applies to both status mapping and detail sections cases.

### Namespaces
* Status Mappings: All onfigmaps are searched for in the same namespace as the KindActionMapping resource.
* Detail Section Mappings: Instance specific configmaps are searched for in the resource's namespace. All other configmaps are searched for in the same namespace as the KindActionMapping resource.

### Merge Considerations
* Status mapping: it has no "name" and "subkind" elements so merge does not apply to it. 
* Detail sections: could merge, but only implement it as needed.
* Resources with the same precedence value are processed together so arbitrary order applies

## Examples of statusMappings and detailsMappings
```
mappings:
 - apiVersion: ‘*’
  kind: ‘*’
  mapname: kappnav.actions.${kind}
statusMappings:
 - apiVersion: ‘*’
  kind: ‘*’
  mapname: kappnav.status.${kind}
detailsMappings:
 - apiVersion: ‘*’
  kind: ‘*’
  mapname: kappnav.details.${kind}
```
## Related design document links:
* [Kind-Action Mapping](https://github.com/kappnav/design/blob/master/actions-config-maps.md)
* [Application and Component Status](https://github.com/kappnav/design/blob/master/status-determination.md)
* [UI Detail Sections](https://github.com/kappnav/design/blob/master/ui-detail-sections.md)
