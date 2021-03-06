# NLS Support for User-defined Actions

User defined actions can support or not support language translation (NLS) as they choose. To support NLS, translation text is required for text and description fields for resource action definitions - e.g. for menu items.  This is supported on all action types - e.g. url-actions, cmd-actions. 

The basic concept is that a lookup key is used to index a language-specific map to obtain the correct text for the user's selected language. 

## Specifying NLS Configuration

The following fields in an action configmap control whether and how NLS is supported for an action: 

| Field Name      | Scope      | Field Value | Description | 
|-----------------|------------|-------------|-------------|
| text.nls        | action     | nls-key     | Optional. Specifies the lookup key for a text translation in an NLS config map. The default is to use the value of the 'text' field. |
| description.nls | action     | nls-key     | Optional. Specifies the lookup key for a description translation in an NLS config map. The default is to use the value of the 'description' field. |
| nls-validation  | configmap  | enabled \| disabled | Optional. Specifies if NLS validation is enabled or disabled. The default is enabled. | 
| nls-configmap   | configmap  | configmap name | Optional. Specifies name of a ConfigMap resource containing language translation values. Default name is 'kappnav.actions.nls.[locale]' |

##  NLS Specification and Operation

### text.nls field

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


### description.nls field 

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

### nls-configmap field 

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

### NLS string lookup

When "text.nls" is not specified, the value of the "text" field is returned. When "description.nls" is not specified, the value of the "description" field is returned. 

When text.nls or description.nls is specified, a lookup will occur in the action configmap's nls-configmap, using the specified translation key and locale.  

We can't always get a perfect locale match for a given request, e.g. we may not have a French Canadian translation, but we have a French one. The rules for resolving a locale into a suitable translation are:

e.g. for a given action configmap, locale fr_CA

```
Try the action configmap's nls-configmap - e.g. kappnav.actions.nls.fr_CA (perfect match)
If not found, try nls-configmap - e.g. kappnav.actions.nls.fr (French)
If not found, try nls-configmap - e.g. kappnav.actions.nls.en (default, English)
```

### nls-validation field 

Specifies if NLS validation is enabled or disabled. The default is 'enabled'. The purpose of NLS validation is to give a visual cue of whether or not the translation strings for the specified locale for a given action definition were found. 

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

1. no text.nls or description.nls values specified
1. no nls configmap found
1. no matching key in nls configmap found

### Provided translations 

The kAppNav project provide translations for actions and all user facing strings in the UI for these language_country combinations, given in the default nls configmap name: 

| nls configmap name | language, country | 
|--------------------|-------------------|
| kappnav.actions.nls.en | English	|	
| kappnav.actions.nls.ja | Japanese |
| kappnav.actions.nls.de | German |
| kappnav.actions.nls.ko | Korean |
| kappnav.actions.nls.es | Spanish	|	
| kappnav.actions.nls.pt_BR | Portuguese, Brazil |
| kappnav.actions.nls.fr | French		|
| kappnav.actions.nls.zh_CN | Chinese, China |
| kappnav.actions.nls.it | Italian |
| kappnav.actions.nls.zh_TW | Chinese, Taiwan |

### Action Input

Actions can optionally specify user input. The UI implementation for this creates a pop up dialog for the user to enter the required inputs.  Several input fields specify user-facing text. This user-facing text is currently assumed to be specified in US_en locale.  Users need the ability to specify user-facing text for other locales.  The format for an action input specification is given below in yaml format: 

```
inputs: 
  <input-name>: 
    title: <input-title>
    fields: 
      <field-name>:
        label: <field-label>
        label.nls: <field-label-translation-key>
        type: <field-type>
        size: <field-size>
        description: <field-description>
        description.nls: <field-description-translation-key>
        default: <default-value>
        default.nls: <default-value-translation-key>
        optional: "true" | "false" 
        validator: <snippet-name>
```

Using facing-fields are label, description, and default;  the following fields support specification of translation keys for each of these fields, respectively: 

1. label.nls
1. description.nls
1. default.nls 

#### Validator Error Messages

Validator snippets are defined to return the following JSON structure: 

```
{ 'valid': true | false, 
  'message': '<error message>', 
  'message.nls': '<message-translation-key>' }
```

Where <message-translation-key> specifies the optional NLS translation lookup key.  

E.g.

```
{ 'valid': false, 
  'message': 'Trace string is required!', 
  'message.nls': 'SNIPPET_TRACE_STRING_MISSING'}
  ```

#### NLS Config Map Lookup

All NLS translation keys for input fields and input validators are specified and looked up in the NLS Config Map specified in the action config map in which the input and validator is defined. 

### API Support 

The "application", "applications", and "components" APIs will support a 'locale' query parameter to allow the caller to specify the desired locale for translation.  It is an optional query parameter.  The default value is "en_US". 
