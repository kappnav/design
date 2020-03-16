# NLS Support for User-defined Actions

User defined actions can support or not support language translation (NLS) as they choose. To support NLS, translation text is required for text and description fields for action menu items.  This is supported on all action types - e.g. url-actions, cmd-actions. 

## Specifying NLS Configuration

The following fields in an action configmap control whether and how NLS is supported for an action: 

| Field Name | Field Value | Description | 
|------------|-------------|-------------|
| text.nls   | nls-key     | Specifies the lookup key for a text translation |
| description.nls | nls-key | Specifies the lookup key for a description translation |
| nls-validation | enabled \| disabled | Specifies if nls validation is enabled (default) or disabled | 
| nls-configmap-provided | true \| false | Specifies whether or not a configmap of nls translations is provided. The default is false |

##  NLS Operation

### text.nls

Specifies the lookup key for a text translation 

### description.nls 

Specifies the lookup key for a description translation 

### nls-validation 

Specifies if nls validation is enabled (default) or disabled 

### nls-configmap-provided 

Specifies whether or not a configmap of nls translations is provided. The default is false 
