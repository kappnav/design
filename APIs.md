# {k}AppNav APIs 
{k}AppNav provides REST APIs on the Kubernetes internal network for the following: 

1. applications
1. components 
1. action substitutions 

## Applications 

Get applications. 

https://host:port/prism/applications[?namespace={specified-namespace}]

Parameter namespace is optional.  If omitted, applications across all namespaces are returned. 

New for version x.x.x.

https://host:port/prism/applications[?namespace={specified-namespace}][{?|&&}locale={locale-value}]

Parameter locale is optional.  The value is a locale value in language_country format. Default value is "en_US".  The locale value is used to translate the text and description values of the actions in the return value's action-map: field.  

Returns JSON structure of all application objects and their action maps in this structure: 

```
{ 
    applications:  
        [ 
             {  application: {},  action-map: {} } , ...
        ]
             
} 
```

Where:
1. 'applications' is an array of objects.
2. Each object in the applications array is comprised of an application and action-map.
3. An application is an instance of the [application CRD](https://github.com/kubernetes-sigs/application).
4. An action-map is a config map containing the action definitions belonging to the associated application. 

## Components 

Get application components.  

https://host:port/prism/components/{application-name}[?namespace={specified-namespace}]

'application-name' specifies the name of the application whose components are requested.  

Parameter namespace specifies the namespace in which the specified application exists. Namespace is optional. If omitted, the application is searched for in the default namespace.  

New for version x.x.x.

https://host:port/prism/components/{application-name}[?namespace={specified-namespace}][{?|&&}locale={locale-value}]

Parameter locale is optional.  The value is a locale value in language_country format. Default value is "en_US".  The locale value is used to translate the text and description values of the actions in the return value's action-map: field.  

Returns JSON structure of all application components and their action maps, according to the application's selection criteria. The selection criteria is part of the application definition, according to the componentKinds and label selector attributes of the application instance. 

The application's selector attribute is a standard [Kubernetes label selector](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/). The label selector is applied to the Kubernetes resources of each kind specified by the componentKinds attribute.  Those that match are the result set. The result set has the following format: 

```
{ 
    components:  
        [ 
             {  component: {},  action-map: {} } , ...
        ]
             
} 
```
Where:
1. 'components' is an array of objects.
2. Each object in the components array is comprised of a component and action-map.
3. A component is an instance of any Kubernetes resource. Each component has a 'kind' attribute (e.g. deployment, service, etc)
4. An action-map is a config map containing the action definitions belonging to the associated component. 


For reference, here are examples of an application's componentKinds and selector attributes: 

```
  componentKinds:
    - group: core
      kind: Service
    - group: apps
      kind: Deployment
    - group: apps
      kind: StatefulSet

  selector:
    matchLabels:
     solution: "stock-trader"
    matchExpressions:
    - {key: app, operator: In, values: [trader, portfolio]}
    - {key: environment, operator: NotIn, values: [dev, qa]}
```

Valid operators include In, NotIn, Exists, and DoesNotExist. The values set must be non-empty in the case of In and NotIn. All of the requirements, from both matchLabels and matchExpressions are ANDed together – they must all be satisfied in order to match.

## Actions and Action Substitution Resolver API 

### Actions API

*Note* Actions are returned also as part of the output from the [applications](https://github.com/kappnav/design/blob/master/APIs.md#applications) and [components](https://github.com/kappnav/design/blob/master/APIs.md#components) APIs. 

https://host:port/prism/resource/{resource-name}/{resource-kind}/actions[&namespace={specified-namespace}]

Where: 

- resource-name specifies the name of the resource to which the specified action applies.
- resource-kind specifies the Kubernetes resource kind for the resource named by resource-name, above. 
- actions indicates the request is to return an action. 
- namespace specifies the optional namespace in which the specified resource exists. The default is 'default'. 

Returns merged actions for this resource: 

{
    url-actions: [ action-object-1, action-object-2, etc ] 
}

See [action config maps](https://github.com/kappnav/design/blob/master/actions-config-maps.md) for complete syntax of url-actions. 

### Action Substitution Resolver API 

The action substitution resolver API accepts an action config map action pattern string and resolves all substitutions.  

https://host:port/prism/resource/{resource-name}/{resource-kind}?action-pattern={action-pattern}[&namespace={specified-namespace}]

Where: 

- resource-name specifies the name of the resource to which the specified action applies.
- resource-kind specifies the Kubernetes resource kind for the resource named by resource-name, above. 
- action-pattern specifies the action pattern string to resolve.  
- namespace specifies the optional namespace in which the specified resource exists. The default is 'default'.  

Optional input: 

{"\<key-1\>": "\<value-1\>", "\<key-2\>": "\<value-2\>", "\<key-3\>": "\<value-3\>", ... } 

Specifies an array of key/value pairs to support substitution via the ${input.\<field-name\>} operator.  E.g. 

```
If the input action pattern contains the expression '${input.trace-string}', them the input parameter to this API would have to contain the following in order for resolution to complete: 

{"trace-string": "com.ibm.*=all"}

```

#### Normal Return

Returns resolved action string in JSON: 

{ "action": "\<resolved-action-string\>" } and return code is 200. 

Resolution takes places as per [config action patterns design](https://github.com/kappnav/design/blob/master/actions-config-maps.md#config-action-patterns).

Example: 

| Action Pattern String                         | Resolved String                                 | 
|:----------------------------------------------|:------------------------------------------------|
| ${snippet.create-kibana-log-url ${builtin.kibana-url} ${func.podlist(${resource.metata.name})}} | https://9.42.75.15:8443/kibana/liberty-dash?pods=pods1,pod2 | 

#### Error Return 

All errors return an error body: 

```
   {
      "message": "<US English error message>"
   }
```

The status code is: 

- 422 for user input error
- 207 for all other errors 


### Command Action Execution API

The command action execution API accepts an action config map cmd-action name, resolves all substitutions and creates a Kubernetes job from the result. The resolved pattern is expected to be a [Kubernetes pod template](https://kubernetes.io/docs/concepts/workloads/controllers/jobs-run-to-completion/#writing-a-job-spec) as a serialized JSON string.

There are two forms of this API: 

1. To initiate a command action for an application resource kind: 

   https://host:port/prism/resource/{application-name}/execute/command/{command-action-name}[&namespace={application-namespace}](POST) 
 
   - application-name specifies the name of the application to which the specified action applies.
   - command-action-name specifies the action name to use.  Actions are defined in by [action config maps]   (https://github.com/kappnav/design/blob/master/actions-config-maps.md#action-config-map-schema). 
   - namespace specifies the namespace in which the specified application exists. This value is optional. The default is 'default'.
   - x-user (HTTP header) specifies the user that initiated the command action. This value is optional. The default is no value.

1. To initiate a command action for a component of a application:  

   https://host:port/prism/resource/{application-name}/{component-name}/{component-kind}/execute/command/{command-action-name}[?namespace={component-namespace}][&application-namespace={application-namespace}] (POST) 

   - application-name specifies the name of the application that contains this component.
   - component-name specifies the name of the component to which the specified action applies.
   - component-kind specifies the Kubernetes resource kind for the component named by component-name, above. 
   - command-action-name specifies the action name to use.  Actions are defined in by [action config maps](https://github.com/kappnav/design/blob/master/actions-config-maps.md#action-config-map-schema). 
   - namespace specifies the namespace in which the specified resource exists. This value is optional. The default is 'default'.
   - application-namespace specifies the namespace of the application that contains this component. This value is optional. The default is 'default'.
   - x-user (HTTP header) specifies the user that initiated the command action. This value is optional. The default is no value.

#### Normal Response

Both forms of this API return the following values: 

- Kubernetes job created from the resolved config map action pattern:

   { "apiVersion": "batch/v1", "kind": "Job", ... } and return code 200. 

#### Error Response

All errors return an error body: 

```
   {
      "message": "<US English error message>"
   }
```

The status code is: 

- 422 for user input error
- 207 for all other errors 

#### Examples 

1. Command initiated against a component of an application (i.e. from 'component view' page): 

   https://host:port/prism/resource/stock-trader/loyalty-level/Deployment/execute/command/enable-trace?namespace=prod&application-namespace=prod


   ```
   "annotations": {
         "app-nav-job-action-text": "Enable Trace"
   },
   "labels": {
         "app-nav-job-action-name": "enable-trace",
         "app-nav-job-application-name": "stock-trader",
         "app-nav-job-application-namespace": "prod",
         "app-nav-job-component-kind": "Deployment",
         "app-nav-job-component-name": "loyalty-level",
         "app-nav-job-component-namespace": "prod",
         "app-nav-job-component-sub-kind": "liberty",
         "app-nav-job-type": "command",
         "app-nav-job-user-id": "admin"
    }
   ```

1. Command initiated against an application (i.e. from 'application view' page): 

   https://host:port/prism/resource/stock-trader/execute/command/calculate-pi?namespace=prod


   ```
   "annotations": {
         "app-nav-job-action-text": "Calculate PI"
   },
   "labels": {
         "app-nav-job-action-name": "calculate-pi",
         "app-nav-job-application-name": "stock-trader",
         "app-nav-job-application-namespace": "prod",
         "app-nav-job-type": "command",
         "app-nav-job-user-id": "admin"
    }
   ``` 

1. Command initiated against a component that IS an application (i.e. from 'component view' page): 


   https://host:port/prism/resource/bookinfo/details-app/Application/execute/command/refresh?namespace=bookinfo&application-namespace=bookinfo

   ```
   "annotations": {
         "app-nav-job-action-text": "Refresh Details"
   },
   "labels": {
         "app-nav-job-action-name": "refresh",
         "app-nav-job-application-name": "bookinfo",
         "app-nav-job-application-namespace": "bookinfo",
         "app-nav-job-component-kind": "Application",
         "app-nav-job-component-name": "details-app",
         "app-nav-job-component-namespace": "bookinfo",
         "app-nav-job-type": "command",
         "app-nav-job-user-id": "admin"
    }
   ```
   
## Command Action Query 

The command action query API returns command 

https://host:port/prism/resource/command[?user={user-name}][{?|&}time={time-later}][{?|&}locale={locale-value}]


Return value is json: 

```

{
  "commands": [
    { "kind": "Job", ... },
    { "kind": "Job", ... },
    etc
  ]
}
 ```

**New for {k}AppNav 0.1.4**

Returns also a job action map: 

```
{
  "commands": [
    { "kind": "Job", ... },
    { "kind": "Job", ... },
    etc
  ],
  "action-map": { ... } 
}
```

**Query Parameters**

- user - specifies user name of job owner.  When this optional parameter is specified, only jobs with matching owner are returned. Otherwise all jobs are returned. 

**New for {k}AppNav 0.1.5:**

- time - specifies job completion time stamp in  "yyyy-MM-dd'T'HH:mm:sss" format.  When this optional parameter is specified, only jobs with completion time stamp newer than specified time stamp are returned. Otherwise, completion time is not considered.

**New for {k}AppNav x.x.x:**
  
- locale specifies the caller's requested lanuage for translation of translatable fields. It is optional.  The value is a locale value in language_country format. Default value is "en_US".  The locale value is used to translate the text and description values of the actions in the return value's action-map: field.  


## Namespace API 

The namespace API is a convenience API that simply passes through to the Kubernetes api/v1/namespaces API.  This is done to simplify security and configuration for the {k}AppNav UI. 

https://host:port/prism/namespaces 


# Status Management APIs 

Requirement:  prism status must be stored in resources (i.e. returned via kubectl get) 

Status design documented [https://github.com/kappnav/design/blob/master/status-determination.md](here.)

1. API that returns all applications and their component kinds. 

   This API will be called by Prism Resource Controller during startup to get the initial list of resource types on which to set watches. The existing applications API satisfies this need. 

1. API that returns application and its component kinds.  

   This API will be called by Prism Resource Controller anytime a new application is created. The existing application API satisfies this need.

1. API that consumes a lifecycle event for a specific resource and does following:
   1. for create - calculate object's status and store it inside resource. 
   1. for update - calculate object's status and store it inside resource. 
   1. for delete - calculate object's status and store it inside resource. 

   When speciied resource is application, this action must be recursive, i.e. walk application's component list and calculate its status.  Application can contain application, so must ensure API can handle that case, too, and safe guard against endless loop in case of incorrectly configured application that contains a cycle (e.g. app A contains app B contains app A). 
