# Extend KAM to Status Mappings and Detail Sections

The application and component status and UI detail sections are configured with ConfigMaps. The KAM schemes of mapping resouce kind to status config maps or detail section config maps are mostly the same as the one for the KAM mapping scheme to map resource kind to action configmaps described in [Kind-Action Mapping](https://github.com/kappnav/design/blob/master/actions-config-maps.md) and with some differences, which are described in this document. With the new mapping scheme, a status config map or detail section config map can exist outside kappnav namespace.

## New Additions to the KAM Custom Resource Definition
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
        type: string
      ownerUID:
        type: string 
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
        type: string
      ownerUID:
        type: string 
      kind: 
        type: string
      name: 
        type: string
      mapname: 
        type: string 
```
  
### Specification
* No subkind or named element
* No concept of merge


## UI Details Sections

### New Addition to the KAM Custom Resource Definition
```


        
detailsMappings:
 - apiVersion: ‘*’
   kind: ‘*’
   mapname: kappnav.details.${kind}
```

### Specification
* No subkind but have named element
* No concept of merge now, but logically it could be extended to support merge

## Related design document links:
* [Kind-Action Mapping](https://github.com/kappnav/design/blob/master/actions-config-maps.md)
* [Application and Component Status](https://github.com/kappnav/design/blob/master/status-determination.md)
* [UI Detail Sections](https://github.com/kappnav/design/blob/master/ui-detail-sections.md)
