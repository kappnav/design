# NLS Support for User-defined Actions

User defined actions can support or not support language translation (NLS) as they choose. To support NLS, translation text is required for text and description fields for resource action definitions - e.g. for menu items.  This is supported on all action types - e.g. url-actions, cmd-actions. 

The basic concept is that a lookup key is used to index a language-specific map to obtain the correct text for the user's selected language. 

## Specifying NLS Configuration

The following fields in an action configmap control whether and how NLS is supported for an action: 

| Field Name      | Scope      | Field Value | Description | 
|-----------------|------------|-------------|-------------|
| text.nls        | action     | nls-key     | Specifies the lookup key for a text translation in an NLS config map. |
| description.nls | action     | nls-key     | Specifies the lookup key for a description translation in an NLS config map. |
| nls-validation  | configmap  | enabled \| disabled | Specifies if NLS validation is enabled (default) or disabled. | 
| nls-configmap   | configmap  | configmap name | Specifies name of a ConfigMap resource containing language translation values.  |

##  NLS Operation

### text.nls

Specifies the lookup key for a text translation in an NLS config map. This value is specified on individual action definitions in an action configmap. It is an optional value.  If not specified, the text field is used for the action text - e.g. as the text for a menu item.  If specified, it is used in combination with the specified locale to lookup the text value from the associated NLS configmap. 

Example specification in an action configmap: 

```
data:
  url-actions: | 
    [
       {
          "name": "homepage"
          "text": "View home page" 
          "text.nls": "view-home-page"
          ...   
       }
    ]
```


### description.nls 

Specifies the lookup key for a description translation in an NLS config map. This value is specified on individual action definitions in an action configmap. It is an optional value.  If not specified, the description field is used for the action description - e.g. as the hover help for a menu item.  If specified, it is used in combination with the specified locale to lookup the description value from the associated NLS configmap. 

Example specification in an action configmap: 
 
```
  url-actions: | 
    [
       {
          "name": "homepage"
          "text": "View home page" 
          "text.nls": "view-home-page"
          "description": "View home page for selected service"
          "description-nls": "view-home-page-desc"
          ...   
       }
    ]
    
```

### NLS string lookup

When "text.nls" is not specified, the value of the "text" field is returned. When "description.nls" is not specified, the value of the "description" field is returned. 

When text.nls or description.nls is specified, the following lookup occurs for each according to the specified locale: 

1. the NLS configmap name 


We can't always get a perfect locale match for a given request, e.g. we may not have a French Canadian translation, but we have a French one. The rules for resolving a locale into a suitable translation are:

e.g. for bundle msgs.properties, locale fr_CA

Try msgs_fr_CA.properties (perfect match)
If not found, try msgs_fr.properties (French)
If not found, try msgs.properties (default, English)



### nls-validation 

Specifies if NLS validation is enabled (default) or disabled.

Example specification in an action configmap: 

```
data: 
   nls-validation: disabled 
   url-actions: [ ... ]
```

If NLS validation is enabled, the effective "text" and "description" value for the defined action is surrounded by exclamation points if validation fails, e.g. 

```
!View home page!
```

Validation fails for any of the following reasons: 

1. no 


### nls-configmap

Specifies the name of a configmap containing the NLS strings for one or more action configmaps. 

Example specification in an action configmap: 

```
apiVersion
data: 
   nls-configmap: kappnav.actions.nls.[locale-value]
   url-actions: [ ... ]
```

### NLS ConfigMap Format

The NLS configmap is a regular configmap where the data section contains key/value pairs as follows: 

```
data: 
    translation-test-lookup-key: translation-text
```

Example NLS configmap:

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: kappnav.actions.nls.es
data: 
  "view-home-page": "ver página de inicio"
  "view-home-page-desc": "Ver página de inicio para el servicio seleccionado"
```

Note the NLS configmap resides in the same namespace as the specifying action configmap.  
