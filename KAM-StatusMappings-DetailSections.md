# Extend Kind Action Mapping to Status Mappings and Detail Section Mappings

Application and component status](https://github.com/kappnav/design/blob/master/status-determination.md) and [UI detail sections](https://github.com/kappnav/design/blob/master/ui-detail-sections.md) allow extension of kAppNav functionality. They defined in config maps and can be defined for individual kinds. Originally, these config map names were of fixed name and constrained to exist within the kAppNav namespace. 

To overcome this limitation, the [KAM]((https://github.com/kappnav/design/blob/master/actions-config-maps.md)) scheme of mapping a resource kind to an action config map will be extended to to support also status config maps or detail section config maps.

## New Additions to the KAM Custom Resource Definition
Addtional mapping rules that map a resouce to a status config map or a set of detail section configmap are provided to the existing KAM custom resouce defintion as below. 

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
      subkind: 
        type: string
      name: 
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
      subkind: 
        type: string
      name: 
        type: string
      mapname: 
        type: string 
```
## Config Map Determination

All mapping, hierarchy, precedence, and namespace rules apply equally to status and detail mappings.  However, there is one difference:  only the most specific config map found (i.e. "top of hiearchy") is used.  I.e. the most specific config map overrides all other, less specific mappings.  

## Default Mapping for status and detail sections. 

These are extensions to the [default KAM resource](https://github.com/kappnav/design/blob/master/kind-action-mapping.md#pre-defined-kindactionmapping-custom-resource), created by kAppNav.

```
statusMappings:
  - apiVersion: ‘*’
    kind: ‘*’
    mapname: kappnav.status-mapping.${kind}
  - apiVersion: ‘*/*’
    kind: ‘*’
    mapname: kappnav.status-mapping.${kind}
detailsMappings:
   - apiVersion: ‘*’
     kind: ‘*’
     mapname: kappnav.sections.${kind}
   - apiVersion: ‘*/*’
     kind: ‘*’
     mapname: kappnav.sections.${kind}
```

## Related design document links:
* [Kind-Action Mapping](https://github.com/kappnav/design/blob/master/actions-config-maps.md)
* [Application and Component Status](https://github.com/kappnav/design/blob/master/status-determination.md)
* [UI Detail Sections](https://github.com/kappnav/design/blob/master/ui-detail-sections.md)
