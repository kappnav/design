# Application and Component Status

kAppNav shows application and component status as labeled and colored indicators to indicate whether an application or component is operating as Normal (Green), operating with Warning (Yellow), or having a Problem (Red). A further status value of Unknown (Grey) covers [special cases](https://github.com/kappnav/design/blob/master/status-determination.md#special-cases). Components map their actual status to a particular kAppNav status value;  applications map their kAppNav status value as a highest severity summary of component kAppNav status as follows: 

| application status | component status | 
|:-------------------|:-----------------|
| Normal | no components have Unknown , Warning, or Problem status | 
| Unknown | at least one component has an unknown status; none have Warning or Problem |
| Warning | at least one component has Warning status; none have Problem | 
| Problem | at least one component has Problem status | 

## Rationale for Using Colors 

The rationale for using labeled colors instead of resource status text (e.g. { Desired=1, Available=1 }, etc) is because ...

1. The application status is a highest severity rollup of the status of the composed Kubernetes resources comprising the application.
1. Any number of distinct Kubernetes resource kinds can be composed into an application. 
1. There is no standard, nor required, set of status values for Kubernetes resources - they sub-resources (objects) of varying types; hence no way to roll them up rationally.  Therefore a color scheme is used to simplify visualization and enhance understanding. 
1. An optional config map can be used per resource kind to map Kubernetes resource status values to text/colors pairs - e.g. status.state=Running -> Normal/GREEN, status.desired > status.available -> Warning/YELLOW, etc. Sensible defaults will be established for all built-in resources. A default mapping will be used for all custom resources definitions (CRDs) for which the CRD owner does not provide a kind specific status mapping. 
1. Fly over text will display the actual status text (component level view only).  

## Terminology

Kubernetes resources have a status sub-resource (object).  This will be referred to as 'resource status'.  Resource status is defined by each Kubernetes resource kind.   

kAppNav assigns an operational status to resources that are components of applications and to applications themselves.  This will be referred to as 'kAppNav status'.   kAppNav status is comprised of the following elements: 

1. value: \<status value\> 
1. flyover: \<text\> 

kAppNav status values map to colors as defined in the [kappnav-config map](https://github.com/kappnav/design/blob/master/status-determination.md#status-value-and-color-configuration).

## kAppNav Status Representation and Storage 

kAppNav Status will be calculated by a controller and stored as annotations in this form: 

```
annotations: 
   kappnav.status.value: <status value>
   kappnav.status.flyover: <text>
```

## kAppNav Status value and color configuration

The value to color mapping will be configurable, so the color scheme can be externally adjusted to satisfy a user's taste.  In the first implementation, this will be a system wide mapping only.  A future per-user mapping is possible. 

While color mapping is the principle objective, the design will satisfy these requirements for future extensibility: 

1. the user external is a color name rather than a machine number 
2. the UI does not require a priori knowledge of the color name -> machine number mapping 
3. the user can extend the model with user defined kAppNav status values and colors


Therefore,

- \<kAppNav status value\>: \<color_name\> # satisfies requirement #1 
- \<color_name\>: \<color_value\> # satisfies requirement #2 
- \<kAppNav status value\> and \<color_name\> together satisfy requirement #3 

e.g. 

```
Normal: GREEN
GREEN: #5aa700

Sort-of-OK: BLUE
BLUE: #6ca501

Unknown: GREY
GREY: #5ba203
```

The value/color configuration will be stored in config map `kappnav-config` in the kappnav namespace.  It will have this structure and default value: 

```
apiVersion: v1
kind: ConfigMap
metadata: 
  name: kappnav-config
  namespace: kappnav
data:
    status-color-mapping: |  
            { "values": { "Normal": "GREEN",   "Warning": "YELLOW",  "Problem": "RED",  "Unknown": "GREY"}, 
              "colors": { "GREEN":  "#5aa700", "YELLOW":  "#B4B017", "RED": "#A74343", "GREY":"#808080"} 
            }
    app-status-precedence: |  
            [ "Problem", "Warning", "Unknown", "Normal" ] 
    status-unknown: "Unknown" 
``` 

## kAppNav Status Value Determination Algorithm for Application Resource 

The app-status-precedence value from the kappnav-config config map specifies the precedence order for summarizing component status to establish application status. The algorithm evaluates the status values left to right in the order given; if any component is found with the current status value, that value is assigned to the kappnav.status.value annotation for that resource. 

## Special Cases 

There are edge cases where kappnav status is unknown:

1. resource created, but controller has not yet assigned kappnav status
1. status API encounters an error while applying status config map rule
1. application has no components 

In all these cases, the "unknown status" is used.  The "unknown status" is defined by the "status-unknown" key in the kappnav-config ConfigMap (see above).  This key specifies a key for the status-color-mappings.values[\<key\>] map.  

The unknown status is used: 

1. By the status API To establish the return value if it cannot determine the status of a resource. 
1. By the UI for any resource that does not have a kappnav.status annotation. 


## kAppNav Status Value Determination Algorithm for all Other Resources 

Each Kubernetes resource declares it's own resource status values.  Some are simple and can be matched using a json path expression against a set of values, like Pod status.phase=Running.  Others are complex, like Deployment as an example: 

```
    
Green:     
    "status": {
        "availableReplicas": 1,
        "observedGeneration": 1,
        "readyReplicas": 1,
        "replicas": 1,
        "updatedReplicas": 1
    }

Yellow:     
    "status": {
        "availableReplicas": 1,
        "observedGeneration": 2,
        "readyReplicas": 1,
        "replicas": 2,
        "updatedReplicas": 2
    }

Red:
    "status": {
        "replicas": 1,
        "observedGeneration": 3,
        "availableReplicas": 0,
        "updatedReplicas": 1
    }

```

Because each resource kind defines its own meaning for its resource status, there is no single mapping of resource status to kappnav status. Therefore, kappnav status is determined on a per resource kind basis, using a kind resource status mapping.  A resource kind status mapping may be registered for any kind, including custom resource definitions.

### Provided Resource Kind Status Mappings

kAppNav installs kind resource status mappings for resources commonly composed into applications.  The following table shows the resource kinds with pre-defined mappings and their mapping rules:  


| Kind   | kAppNav Status Value | Conditions                  | Comment                    |
|:-------|:-------------|:----------------------------|:---------------------------| 
| Deployment | Problem | available=0 and replicas > 0 |  
| Deployment | Warning | replicas > available | 
| Deployment | Normal | replicas = available |
| StatefulSet | Problem | available=0 and replicas > 0 |  
| StatefulSet | Warning | replicas > available | 
| StatefulSet | Normal | replicas = available |
| Pod | Unknown | status.phase = Unknown | 
| Pod | Problem | status.phase = Failed or CrashLoopBackOff |  
| Pod | Warning | status.phase = Pending | 
| Pod | Normal | status.phase = Running, Succeeded, or Completed  |
| Service | Problem | N/A | Services are never Red |  
| Service | Warning | N/A | Services are never Yellow |  
| Service |Normal | Service instance exists | 
| Ingress | Problem | N/A | Ingresses are never Red |  
| Ingress | Warning | N/A | Ingresses are never Yellow |  
| Ingress |Normal | Ingress instance exists | 
| WAS-Traditional-App | Problem | status.value = Stopped | Stopped could mean either the app is stopped or the app server is stopped | 
| WAS-Traditional-App | Warning | status.value = Unknown | Unknown means an error occurred while gathering status | 
| WAS-Traditional-App | Normal | status.value = Running | 
| WAS-Liberty-App | Problem | status.value = Stopped | Stopped could mean either the app is stopped or the app server is stopped | 
| WAS-Liberty-App | Warning | status.value = Unknown | Unknown means an error occurred while gathering status | 
| WAS-Liberty-App | Normal | status.value = Running | 

See [Status Mapping Definition](#kind-status-mapping-definition) for information on registering a status mapping for a kind. 

### Unregistered Kinds

This is the default kind status mapping for unregistered kinds: 

| Kind   | kAppNav Status Color | Conditions                  | Comment                    |
|:-------|:-------------|:----------------------------|:---------------------------| 
| Unregistered Kind | Problem | N/A | Unregistered kinds never have Problem status. |  
| Unregistered Kind | Warning | N/A | Unregistered never have Warning status.  |  
| Unregistered Kind | Normal | Instance exists | 

### Kind Status Mapping Definition 

A kind status mapping can be defined for a kind and registered to replace kAppNav defaults or registered for a previously unregistered kind.  A kind status mapping is a Kubernetes config map in the kappnav name space.  You register a kind status mapping simply by creating the configmap instance. 

Kind Status Mapping Schema: 

```
apiVersion: v1
kind: ConfigMap
metadata: 
  name: kappnav.status-mapping.{kind}
data:
    "exists": | 
    { 
        "value": "Problem" | "Warning" | "Normal",
        "flyover": "< flyover text >",
        "flyover.nls": "< flyover nls array >"
    }
    "jsonpath": | 
    {
      "expression": "< jsonpath-expression >",  
      "matches":  {  
            "< path-value >" : 
            {  
               "value": "Problem" | "Warning" | "Normal" | "Unknown" , 
               "flyover": "< flyover text >",
               "flyover.nls": "< flyover nls array >"               
            },
            ...
      }, 
      "else": {
            "value": "Problem" | "Warning" | "Normal" | "Unknown" , 
            "flyover": "< flyover text >",
             "flyover.nls": "< flyover nls array >"
      }
    }     
    "algorithm": | 
        function getStatus(status) { < javascript > }
```

Where: 

| Specification | Value                         | Comment                  | 
|:--------------|:------------------------------|:-------------------------|
| name:  | {kind} specifies the kind to which this mapping applies. |
| exists: | component status value and flyover text for when instance exists. | Specifies whether or not existence alone conveys component status and what status value and flyover to use.  | 
| jsonpath: | Specifies a json path expression applied against the resource's status object (sub-resource) and a map of values to match against. |  A json path status mapping is resource 'status' with a color value of either Problem, Warning, or Normal, plus flyover text. | 
| algorithm: | Specifies a JavaScript snippet of the form 'function getStatus(status)' that returns the component status value color and fly over text. | Receives resource's status object as input and must return following json object: <br> { value: Problem \| Warning \| Normal \| Unknown, flyover: \<text\> } | 

**Notes**

1. 'exists' is mutually exclusive with 'jsonpath' and 'algorithm' if you specify 'exists', it overrides all other status-mapping specifications and means that the resource has a status of the indicated status value if and only if it exists. 
1. 'jsonpath' is mutually exclusive with 'exists' and 'algorithm'. If 'jsonpath' is specified, it must provide a status mapping for as many text status values returnable from the jsonpath expression that you want to explicitly map to a status value. Else is used for all others. If Else is omitted and the jsonpath expression returns a value that does not match any of the specified match values, then the 'unknown' status value is assigned. 
1. 'algorithm' is mutally exclusive with 'exists' and 'jsonpath'.  If 'algorithm' is specified, it specifies a javascript snippet that accepts the resource's JSON status value as an input parameter and is responsible to return the correct component status object, containing status value and flyover text. 

1. kappnav.status-mapping-unregistered

   This is a special status config map with a reserved name.  It provides the resource status mapping for any kind that does not have an explicit resource status mapping.  It is a reserved config map name in the kappnav namespace. 

### kAppNav-installed mappings:

```
apiVersion: v1
kind: ConfigMap
metadata: 
  name: kappnav.status-mapping.service
  namespace: kappnav 
data:
  exists: |
  {  
    value: "Normal",
    flyover: "Service exists."
  }

apiVersion: v1
kind: ConfigMap
metadata:
  name: kappnav.status-mapping.pod
  namespace: kappnav 
data: 
   "jsonpath": |
   { 
      "expression": "{.phase}",
      "matches": { 
         "running": { "value": "Normal", "flyover": "status.phase is Running" }, 
         "succeeded": { "value": "Normal", "flyover": "status.phase is Succeeded" }, 
         "completed": { "value": "Normal", "flyover": "status.phase is Completed" },  
         "pending": { "value": "Warning", "flyover": "status.phase is Pending" }, 
         "unknown": { "value": "Unknown", "flyover": "status.phase is Unknown" },
         "failed": { "value": "Problem", "flyover": "status.phase is Failed" }, 
         "crashloopbackoff": { "value": "Problem", "flyover": "status.phase is CrashLoopBackOff" }
      }, 
      "else": { "value": "Unknown", "flyover": "${status} is not a known status.phase value" }
   }
     
apiVersion: v1
kind: ConfigMap
metadata: 
  name: kappnav.status-mapping.was-traditional-app
  namespace: kappnav 
data:
  jsonpath: | 

    
apiVersion: v1
kind: ConfigMap
metadata: 
  name: kappnav.status-mapping.was-liberty-app
  namespace: kappnav 
data:
  jsonpath: | 
    { 
      "expression" : "{.status}",
      "matches" : {
        "started": { "value": "Normal", "flyover": "Liberty application running" },
        "unknown": { "value": "Unknown", "flyover": "Liberty application status unknown" }, 
        "stopped": { "value": "Warning", "flyover": "Liberty application stopped" }
      }
    }
    
apiVersion: v1
kind: ConfigMap
metadata:
  name: kappnav.status-mapping.deployment
  namespace: kappnav 
data:
  algorithm: | 
    function getStatus(status) {
      var statusJson = JSON.parse(status);
      var replicas = statusJson.replicas;
      var available = statusJson.availableReplicas;
      var statusText = 'Unknown';
      var statusFlyover; 

      if (!replicas) replicas = 0;
      if (!available) available = 0;

      if (replicas == available) {
        statusText = 'Normal';
      }
      if (available == 0) {
        statusText= 'Problem';
      } else if (replicas > available) {
        statusText = 'Warning';
      }
      statusFlyover = '\"Desired: ' + replicas + ', Available: ' + available + '\"';
      return '{ value: ' + statusText + ', flyover: ' + statusFlyover + ' }';
    }
    
    
apiVersion: v1
kind: ConfigMap
metadata: 
  name: kappnav.status-mapping-unregistered
  namespace: kappnav 
data:
  exists: |
  {  
    "value": "Normal"
    "flyover": "Resource kind without status mapping"
  }
    
```
