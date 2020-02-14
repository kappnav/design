# Actions Config Maps 

"Actions" are day 2 operations.  Action config maps hold the definition of actions that can be applied to Kubernetes resources.  The principle use of action config maps is to populate the ACTION menus of the Prism Application and Component views.

Each application and application component may have one or more corresponding action config maps.  When there are multiple action config maps for a given Kubernetes resource, they are combined together to form the complete set of actions available for that resource.  

Config maps are returned by the Prism application and component APIs.  [See APIs for more information.](https://github.com/kappnav/design/blob/master/APIs.md)

## Action Config Map Schema

```
apiVersion: v1
kind: ConfigMap
metadata: 
  name: prism.actions.{kind}[-subkind][.name]
  annotations: 
     prism.actions.on.conflict: "merge" | "replace" 
data:
  url-actions: | 
      [
        {  
          "name": "<name>", 
          "text": "<text for menu item>", 
          "description": "<brief description>", 
          "url-pattern": "<substitution-pattern>",
          "open-window": "current" | "tab" | "new ",
          "menu-item": "true" | "false",
          "requires-input": "<input-name>"
        }
      ],  
    cmd-actions: 
      [
        {  
          "name": "<name>", 
          "text": "<text for menu item>", 
          "description": "<brief description>", 
          "image": "<image-name:tag>",
          "cmd-pattern": "<substitution-pattern>",
           "menu-item": "true",
           "requires-input": "<input-name>"
        } 
      ],
    function-actions: | 
      [
        {  
          "name": "<name>", 
          "text": "<text for menu item>", 
          "description": "<brief description>", 
          "parameter-pattern": "<substitution  pattern>", 
           "menu-item": true | false 
        }
      ], 
    inputs: | 
       {
          "<input-name>": {  
             "title": "<input-title>", 
             "fields": { 
                "<field-name>": { "label": "<field-label>", "type" : "<field-type>", "size":"<field-size>", description": "<field-description>", "default": "<default-value>", "values": "<values>", optional= true | false, "<validator>": "<snippet-name>"}, 
... 
              },
          },  
       }
    variables: | 
      {
          "<variable-name>": "<substitution-pattern>"
      }  
    snippets: | 
      {
          "<snippet-name>": "<javascript-function>"
      }
```

**Note:** only url-actions and cmd-actions will be implemented for GA 1.0 MVP and will be detailed here. Design details for function-actions will be added in the future. 

Notable fields in the ConfigMap: 

- metadata.name - config map name. Required. See [Action Config Map Naming Convention](#action-config-map-naming-convention), below, for a full explanation.
- metadata.annotations.prism.actions.on.conflict - specifies whether to merge or replace action config maps within the action configmap hierarchy.  Optional. The default is merge.  See [Action Config Map Hierarchy and Overrides ](#action-config-map-hierarchy-and-overrides) for further explanation of how this works.  
- data.url-actions
  - name - name of this url-action. Must be unique among all url-actions.  Required. 
  - text - display text for action menu item in Prism UI. Used when menu-item= true; ignored otherwise. If menu-item= true and text is not defined,  then description is used; if description is not specified, then name is used. 
  - description - user targetted description for this action.  Optional.  When defined and menu-item= true, the description is displayed as fly over help on the action menu in the Prism UI. 
  - url-pattern - the actual URL used to carry out this action.  See [Config Action Patterns](#config-action-patterns) for a full explanation of how to specify url patterns. 
  - open-window - specifies how to open the URL in a browser:  the value 'current' means in the current window/tab, the value 'tab' means in a new tab, and the value 'new' means in a new window. This value is used only when menu-item= true; otherwise it is ignored.  This value is optional.  The default is 'tab'.  
  - menu-item is a boolean field that indicates whether or not the action is intended for display in the Action menu on UI displays. This field is optional.  The default value is true.  
  - requires-input - specifies the name of an input specification that defines a required input for this action.  This value is optional.  It not specified, there is no required input. 
- data.cmd-actions
  - name - name of this cmd-action. Must be unique among all cmd-actions.  Required. 
  - text - display text for action menu item in Prism UI. Used when menu-item= true; ignored otherwise. If menu-item= true and text is not defined,  then description is used; if description is not specified, then name is used. 
  - description - user targetted description for this action.  Optional.  When defined and menu-item= true, the description is displayed as fly over help on the action menu in the Prism UI. 
  - image - specifies the docker image name and tag of the image that contains the implementation of the command specified by cmd-pattern.  This value is required. 
  - cmd-pattern - the actual command  used to carry out this action.  See [Config Action Patterns](#config-action-patterns) for a full explanation of how to specify cmd patterns.  This is a required value. 
  - menu-item is a boolean field that indicates whether or not the action is intended for display in the Action menu on UI displays. This field is optional.  The default value is true.  
  - requires-input - specifies the name of an input specification that defines a required input for this action.  This value is optional.  It not specified, there is no required input. 
- data.inputs - specifies a map of named input specifications for dynamic input from user.  Each specification includes the following: 
   - title - specifies input title for case in which input is solicited via UI. 
   - fields - specifies an array of fields for which user is to supply values.  Each field specifies following: 
      - name - specifies name of this field.
      - label - specifies display label for this field. 
      - type - field data type.  Supported types are string and integer.
      - size - specifies field size as small (sm), medium (med), or large (lg).  This is a hint to the UI layout to choose set the relative display size of the field. 
      - description - specifies description of field. Used for flyover help in UI. 
      - default - specifies default value if any.  This is an optional specification. If omitted, default for string type is empty string and default for list type is first entry from values array. 
      - values - supported for list type only and must be a json array of scalar values. This is an optional specification.
      - optional - specifies whether value is optional (true) or required (false) 
      - validator - specifies a snippet to validate the field.  

      input: json containing input field value in form: { "value": "\<field-value\>" } 

      output: { "valid": true | false,  "message": "\<error-message\>"}

- data.variables - specifies a variable-name that is assigned a value from a substitution pattern. See [Config Action Patterns](#config-action-patterns) for a full explanation of how to specify substitution patterns.  
- data.snippets
  - snippets-name - specifies the name of a javascript snippet. Snippets are javascript that can be used by the ${snippet.*} operator.  See [Config Action Patterns](#config-action-patterns) for further details. 

    Note that snippets have a naming convention, whereby the snippet name is lower case and underscore delimited.  The corresponding function name is camelcase with underscores removed - e.g.
 
      "create_kibana_log_url": "function createKibanaLogUrl(...) {...}" 

  - javascript-function is a valid javascript function in the form:   

    function \<name\>(\<parameter-list\>) { \<body\>; return \<string-value\>;  } 

## Action Config Map Names 

**{k}AppNav 0.6.0** 

The [KindActionMapping Custom Resource Definition](https://github.com/kappnav/design/blob/master/kind-action-mapping.md) establishes an explicit mechanism for mapping Kubernetes resource kinds to their respective action config map name. This approach supercedes the mapping convention previously used by {k}AppNav.

**{k}AppNav prior to 0.6.0**

The kind-action config map name mapping was done via convention, based on the simple, singular kind name of the resource.  E.g. 'Service' kind mapped to action config map name 'kappnav.actions.service'.  This mapping is now done via configuration, as described in the preceding paragraph.  All other aspects of action config maps, including role of subkind, hierarchy, overrides, etcs, as described in the sections that follow, remain valid. 

**Common Design Applicable to All Versions**

Action config maps correspond to their associated resource according to the name of the action config map or maps; more than one action config map may correspond to the same resource.  The action config map names are formed based on particular fields and annotations of the associated resource. The action config map name is determined from the following resource fields and annotations: 

- kind is the resource's kind field
- subkind is the resource's metadata.annotations.kappnav.subkind annotation. [See annotations for more details.](https://github.com/kappnav/design/blob/master/annotations.md)
- name is the resource's metadata.name field 

One or more action config maps may exist to which the same resource maps.  E.g. 

- kind specific
- kind.name (instance) specific
- kind-subkind specific 
- kind-subkind.name (instance) specific

Example:

| Resource | Valid Action Config Map Names  |
|:-----------|:--------------------------------|
| kind: Deployment <br> metadata.name: trader <br> metadata.annotations.prism.subkind: Liberty  | prism.deployment <br> prism.deployment.trader <br> prism.deployment-liberty <br> prism.deployment-liberty.trader  | 

When multiple action config maps exist for a given resource, they are combined according to the rules for 
[Action Config Map Hierarchy and Overrides](#action-config-map-hierarchy-and-overrides); see below. 

## Action Config Maps and Name Spaces 

Action config maps can be defined in the same namespace as the resource to which they correspond and additionally in a special namespace named 'prism'. The prism namespace is created as part of Prism's installation and serves as a global namespace for prism action config maps. 

So it is possible for a resource to have corresponding action config maps in both its own namespace as well as in the prism global namespace. 

Example:

| Resource | Valid Action Config Map Names  |
|:-----------|:--------------------------------|
| kind: Deployment <br> metadata.name: trader <br> metadata.namespace: production  | namespace: prism <br> &nbsp;&nbsp;&nbsp;prism.deployment <br> &nbsp;&nbsp;&nbsp;prism.deployment-liberty <br> namespace: production <br> &nbsp;&nbsp;&nbsp;prism.deployment-liberty.trader | 

Only kind and kind.subkind specific action config maps are supported only in the prism global namespace.  Instance specific action config maps are supported only in the same namespace as the associated resource. 

When multiple action config maps exist for a given resource, they are combined according to the rules for 
[Action Config Map Hierarchy and Overrides](#action-config-map-hierarchy-and-overrides); see below. 

## Action Config Map Hierarchy and Overrides 

Because more than one action config map can correspond to the same resource, there is a hierarchy and override scheme.
For further details, see [naming](#action-config-map-naming-convention) and [namespace](#action-config-maps-and-name-spaces), above.

The set of action config maps that correspond to a given resource form a hierarchy. This is the supported hierarchy:  

![hierarchy](https://github.com/kappnav/design/blob/master/images/configmap-hierarchy.png)

The potential hierarchy for a given resource is calculated by constructing the action config map names (as per the preceding patterns) and querying for them. The ones actually found comprise the effective hierarchy. Once the effective hierarchy is established, overrides are evaluated from top to bottom.

Overrides may be in whole or in part at each level, based on the setting of the action config map's prism.actions.on.conflict annotation.  When the value is 'replace', the current action config map replaces entirely the evaluation up to that point. In other words, 'replace' replaces all actions higher in the hierarchy with the actions in the current action config map. 

Alternatively, when when prism.actions.on.conflict is 'merge' the current action config map is merged into the actions evaluated up to that point in the hierarchy.  In other words,'merge' merges actions from the current action config map into the actions of the action config maps higher in the hierarcy. The individual action is merged by replacing a named action from higher in the hierarchy with the same-named action in the current action config map; if no such action exists higher in the hierarchy, the action is net new and simply added to the rest.  

Examples: 

```
Given action config maps: 

apiVersion: v1
kind: ConfigMap
metadata:
  name: prism.deployment
  namespace: prism
data:
  url-actions: |
    [ 
        {"name":”config",”description":”Edit Config","url":"https://${server}/serverConfig"}
        {"name":”monitor",”description":”View Monitor","url":"https://${server}/serverMonitor"}
   ]
   
apiVersion: v1
kind: ConfigMap
metadata:
  name: prism.deployment-liberty
  namespace: prism
  annotations: 
    prism.actions.on.conflict: replace  
data:
  url-actions: |
    [ 
        {"name":”config",”description":”Edit Config","url":"https://${production.server}/serverConfig"},
        {"name":”logs",”description":”View Logs","url":"https://${production.server}/serverLog"}
   ]
   
apiVersion: v1
kind: ConfigMap
metadata:
  name: prism.deployment-liberty.myapp
  namespace: default
  annotations: 
    prism.actions.on.conflict: merge   
data:
  url-actions: |
    [ 
        {"name":”logs",”description":”View Merged Logs","url":"https://${production.server}/mergedLogs"},
        {"name":”app",”description":”View Homepage","url":"https://${production.server}/home"}
   ]
   
and Kubernetes resource with:

kind: Deployment
metadata:
    name: myapp
    annotations:
        prism.subkind: Liberty 
        
after action config map evaluation, the effective actions would be: 

        {"name":”config",”description":”Edit Config","url":"https://${production.server}/serverConfig"},
        {"name":”logs",”description":”View Merged Logs","url":"https://${production.server}/mergedLogs"},
        {"name":”app",”description":”View Homepage","url":"https://${production.server}/home"}
```

## Config Action Patterns 

Config action map actions are intended to be expressed as substitution patterns.  This makes it possible for generic action patterns to be reused across multiple resource instances of the same kind (or subkind).  A substitution pattern is a string comprised of literals and substitution symbols. The substitution symbols may be resolved by values from various sources.

substitution symbol sources:

1. built-in symbols
1. resource fields
1. global configmap fields 
1. secret fields 
1. built-in functions 
1. input values 
1. local variables 
1. javascript snippets 

There is a resolution operator and syntax for expressing each substitution symbol source within a config action. The symbols are resolved before the action is usable. There is an API to retrieve the effective actions for a given resource and another API to resolve the substitution symbols. See Action Config Map Hierarchy and Overrides ](#action-config-map-hierarchy-and-overrides) for the definition of 'effective actions'.

The resolution operator is borrowed:  ${\<string\>}

The syntax for expressing resolution of each source is: 

| Source | Syntax | Example | 
|--------|--------|---------|
| resource field | ${resource.\<json-path\>} | ${resource.$.metadata.name} |
| resource annotation | ${resource.\<json-path\>} | ${resource.$.metadata.annotations['prism.subkind']} | 
| global configmap field | ${global.\<configmap-name\>#\<configmap-spec\>} | ${global.dmgrs#cell1-ipname} |
| secret field | ${secret.\<secret-name\>#\<secret-spec\>} | ${secret.dmgr-creds#user} |
| builtin symbols | ${builtin.\<builtin-spec\>} | ${builtin.icp-console-url} |
| built-in functions | ${func.\<function-name\>} | ${func.podlist(\<namespace-name\>,\<deployment-name\>)} ${func.apppodlist(\<namespace-name\>,\<application-name\>)}  ${func.replicaset(\<namespace-name\>,\<deployment-name\>)} |
| input values | ${input.\<field-name\>} | ${input.tracestring} 
| variables | Through release 0.1.4 ${var.\<variable-name\>} | ${var.nodePort}  
| variables | Release 0.1.5 and above ${var.\<variable-name\>[,default.\<string-constant\>]} | ${var.kibanahost,default.undefined} 
| javascript snippet | ${snippet.\<snippet-name\>( \<parameter1\>, \<parameter2\>, etc> )} | ${snippet.create-kibana-log-url} |

Details and Rules:

1. A json-path is a json path reference to any of the standard fields of a Kubernetes resource - e.g. metadata.name. You can use reference child elements using ".child" or "['child'] notation.
1. A configmap-name is the name of a config map. 
1. A configmap-spec is a reference to a named field within a config map's data section.
1. A ${global} reference references a configmap within the prism global namespace. 
1. A secret-name is the name of a secret. 
1. A secret-spec is a reference to a named field within a secret's data section.
1. A ${secret} reference references a secret within the prism global namespace. 
1. A ${builtin} reference references a builtin value.
1. A builtin-spec reference references a builtin value.
1. A ${var.\<variable-name\>} references a named variable. For release 0.1.5 and higher returns either resolved variable value or optional default string constant if value can otherwise not be resolved. 
1. A ${input.\<field-name\>} references a named field from the input definition specified on the required-input specification.
1. A ${func} reference references a builtin function. 
1. A ${snippet} reference references a named javascript snippet found in the immediate action config map. 

Further examples, given:  

```
Resources: 

kind: Deployment
metadata: 
   name: trader 
   annotations: 
       prism.subkind: Liberty
      
configmap: 
   
metadata:
   name: dmgrs
   namespace: prism
data:
   cell1-ipname: cell1.dmgr.com    

action config map: 

apiVersion: v1
kind: ConfigMap
metadata:
  name: prism.deployment-liberty
  namespace: prism
  annotations: 
    prism.actions.on.conflict: merge   
data:
  url-actions: |
  [ 
      {
       "name":”logs",
       ”description":”View Kibana Logs",
       "url":"${snippet.create_kibana_log_url(${builtin.kibana-url},${func.podlist(${resource.$.metadata.namespace},${resource.$.metadata.name})})}",
      }
  ]
  snippets: | 
  {
     "create_kibana_log_url": "function createKibanaLogUrl(kibanaUrl, json) { pods= JSON.parse(json.pods); console.log(kibanaUrl+'/liberty-dash?pods='+pods); }" 
  }
  
Note: 

Return structure format from ${func.podlist}: 

{ "pods" : "['pod1','pod2']"  } 

```
When following expressions are processed against the preceding examples, they yield the indicated results: 

| Expression | Applied Against | Result | 
|:------------|:--------|:--------------|
| ${resource.$.metadata.name} | trader deployment in default namespace  | trader | 
| ${resource.$.metadata.annotations['prism.subkind']} | trader deployment in default namespace | Liberty | 
| ${global.dmgrs#cell1-ipname} | dmgrs config map in prism-global namespace | cell1.dmgr.com | 
| ${builtin.kibana-url} | current Kubernetes cluster | https://9.42.75.15:8443/kibana |  
| ${func.podlist(${resource.$.metadata.namespace},${resource.$.metata.name})} | trader deployment in default namespace | { "pods" : "['pod1','pod2']" } | 
| ${func.replicaset(${resource.$.metadata.namespace},${resource.$.metata.name})} | trader deployment in default namespace | { "replicaset" : "pod1" } | 
| ${snippet.create-kibana-log-url(${builtin.kibana-url},${func.podlist(${resource.$.metata.namespace},${resource.$.metata.name})})} | prism.deployment-liberty config map and trader deployment in default namespace | https://9.42.75.15:8443/kibana/liberty-dash?pods=pod1,pod2 |
| ${snippet.create-kibana-log-url(${builtin.kibana-url},${func.replicaset(${resource.$.metata.namespace},${resource.$.metata.name})})} | prism.deployment-liberty config map and trader deployment in default namespace | https://9.42.75.15:8443/kibana/liberty-dash?replicaset=pod1 |


### Builtin Substitution Symbols 

These are stored in config map 'builtin' in the 'prism' name space. 

| Name | Description |
|:-----|:------------|
| icp-console-url | ICP Console URL |
| kibana-url | Kibana URL |
| liberty-problems-dashboard | Kibana dashboard name for viewing problems in Liberty logs | 
| liberty-traffic-dashboard | Kibana dashboard name for viewing request liberty traffic | 

### Builtin Functions

| Name | Description |
|:-----|:------------|
| podlist(\<namespace-name\>,\<deployment-name\>) or just podlist() for the current Deployment resource | Returns a list of pod names for the specified deployment.  Return value structure is: <br> { "pods" : "[\<name1\>,\<name2\>,etc]"  }  |
| apppodlist(\<namespace-name\>,\<application-name\>) or just podlist() for the current Application resource | Returns list of pod names from all deployments belonging to specified applicationa.  Return value structure is: <br> { "pods" : "[\<name1\>,\<name2\>,etc]"  }  |
| replicaset(\<namespace-name\>,\<deployment-name\>) or just replicaset() for the current Deployment resource | Returns name of specified deployment's replicaset.  Return value structure is: <br> { "replicaset" : "\<name\>"  }  |
| kubectlGet(\<kubectl get parameters\>) | Returns equivalent to command 'kubectl get \<kubectl get parameters\>'| 

### Action Config Map Snippet Interface 

The purpose of an action config map snippet is to provide a way to apply custom programming logic to the formation of an action URL. Action config map snippets are javascript.  They are invoked as a Node.js main.  The input parameters are accessible via the Node.js standard process.argv array.  The snippet must do no I/O. 

Return value

An action config map snippet must write it's return value to stdout using console.log(). The return value is either a valid, fully formed, fully resolved http: or https: URL or an error message. Substitution symbols are not supported in the returned string. 

Error messages are returned in the following format: 

ERROR: \<error message text\>

