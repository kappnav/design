# Custom Resources

The following Kubernetes [Custom Resource Definitions](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/#customresourcedefinitions) (CRD) are introduced for use by Prism: 

1. Application
1. WAS-ND-Cell
1. WAS-Traditional-App
1. Liberty-Collective
1. Liberty-App

## Application CRD

The Prism application viewer is specifically defined to read and display application definitions as defined by the [Application CRD](https://github.com/kubernetes-sigs/application). 

## WAS-ND-Cell 

WebSphere ND cells are represented in Kubernetes by a Custom Resource Definition. A WAS-ND-cell resource holds the network endpoint and login credential information for a WAS ND cell. The WAS-ND-cell resource is referenced by WAS-Traditional-App resources that are installed in the referenced cell.  WAS-ND-Cell resources must be created in the prism namespace. 

WAS-ND-Cell Schema

```
apiVersion: prism.io/v1beta1
kind: WAS-ND-Cell
metadata: 
  name: <cell name>
  namespace: prism 
spec:
    host: <host-name>
    http_port: <port-number>
    https_port: <port-number>
    soap_port: <port-number>
    console_uri: <console-uri>
    credentials: <secret-name>
    interval: <seconds>
status:
    value: ONLINE | OFFLINE 
```

Where: 

| Field | Description | 
|:------|:------------|
| host | Specifies the host name (or ip address) of the WAS dmgr. This is a required value. | 
| http_port | Specifies the port number by which to access the admin console on the WAS dmgr. This is a required value.
| https_port | Specifies the port number by which to access the admin console on the WAS dmgr. This is a required value.
| soap_port | Specifies the port number by which to access the admin scripting (i.e. for wsadmin) on the WAS dmgr.  This is a required value. |
| console_uri | Specifies the uri portion of the admin console URL - i.e. 'console-uri' in the following pattern: http://${host}:${https-port}/${console-uri}. It is an optional specification. The default is 'ibm/console/login.do?action=secure'. |
| credentials | Specifies the credentials needed to login to the cell's dmgr. This is a required value. | 
| interval | Specifies in seconds the amount of time between calls to the dmgr to determine the status of the associated (actual) WAS ND application. This is an optional value.  The default is 30 seconds. | 
| status | Describes status of WAS ND Cell resource.  A value of ONLINE means the cell is accessible over the network.  A value of OFFLINE means it is not. | 

Example: 

```
apiVersion: prism.io/v1beta1
kind: WAS-ND-Cell
metadata: 
    name: wascell-cell1 
    namespace: prism 
spec:
  host: "9.57.4.23"
  http_port: 9060 
  https_port: 9043
  soap_port: 8879 
  credentials: "wascell-cell1"
```


### Cell Login Credentials Secret 

The cell (dmgr) login credentials are stored as Kubernetes secret in the prism namespace: 

```
apiVersion: prism.io/v1beta1
kind: Secret
metadata:
  name: wascell-cell1 
  namespace: prism
type: Opaque
data:
  username: YWRtaW4=
  password: MWYyZDFlMmU2N2Rm
```


## WAS-Traditional-App 

The WAS-Traditional-App represents a J2EE application, deployed on a WAS ND Cell. Its primary purpose is to represent a tWAS cell-hosted app as part of an overall application, as defined by [Application CRD](#application-crd), above. WAS-Traditional-App resources are automatically created through a [discovery process](#was-traditional-app-discovery). 

WAS-Traditional-App Schema

```
apiVersion: prism.io/v1beta1
kind: WAS-Traditional-App
metadata: 
  name: <app-name>
  annotations: 
     prism.platform.kind: WAS-ND-Cell
     prism.platform.name: <cell-name> 
```

Where: 

| Field | Description | 
|:------|:------------|
| prism.platform.kind | Specifies the platform kind is WAS-ND-Cell. This is a required value. | 
| prism.platform.name | Specifies the WAS-ND-Cell instance for this resource. This is a required value.| 

Note: annotations are used where fields could clearly be used instead.  This is for consistency with all other resources, which can only use annotations to store platform info. 

Example: 

```
apiVersion: prism.io/v1beta1
kind: WAS-Traditional-App
metadata: 
    name: trader 
    annotations: 
       prism.platform.kind: WAS-ND-Cell
       prism.platform.name: wascell-cell1  
```

### WAS Traditional App Action Config Map 

WAS ND Apps are configured out of the box to support the following actions: 

1. edit WAS ND App Kubernetes resource 
1. login to WAS Cell Dmgr 
1. view Kibana log for this WAS ND App 

Definition: 

```
apiVersion:  v1
kind: ConfigMap
metadata: 
  name: prism.actions.was-traditional-app
  namespace: prism 
data:
  url-actions: | 
      [
        {  
          "name": "edit", 
          "description": "Edit", 
          "url-pattern": "https://${global.builtin#icp_console_url}/prism/was_traditional_app/${resource.metadata.namespace}/${resource.metadata.name}"
        },
        {  
          "name": "dmgr", 
          "description": "Login to Dmgr", 
          "url-pattern": "${resource.spec.protocol}://${resource.spec.dmgr-host}:${resource.spec.dmgr-port}/${resource.spec.console-uri}" 
        },
        {  
          "name": "logs", 
          "description": "View Kibana Logs", 
          "url-pattern": "https://${global.builtin#kibana_url}/${global.builtin#liberty_log_dashboard}" *** TODO: finish ***
        }
      ]    
```

### WAS-Traditional-App Status Values 

WAS-Traditional-App resources represent a Java EE application running in a WAS ND cell. All Kubernetes resources have a status value. A mapping is used between the status of the Java EE application and the corresponding WAS-Traditional-App resource to establish the status values of the Kubernetes resource.  

The following mapping is used: 

| Java EE Application Status | WAS-Traditional-App Resource Status | 
|:---------------------------|:---------------------------|
| Application started | Started|
| Application stopped | Stopped | 
| Application server starting, stopping, stopped | Stopped | 
| Unknown | Unknown | 

Java EE application status is unknown when any error occurs while attempting to retrieve application server or application status. 

### WAS ND Controller 

The WAS ND Controller is a standard Kubernetes controller for the WAS-Traditional-App custom resource type.  It's primary purpose is to maintain the status of the WAS-Traditional-App resource instances. It does this by periodically querying the dmgr of the cell on which the WAS Traditional app represented by the WAS-Traditional-App resides, and evaluating status of the WAS Traditional App to reflect that accordingly in the status field of the corresponding WAS-Traditional-App resource instance. 

The WAS ND App Controller is implemented in Go, as are all Kubernetes controllers, and delegates most of its function to the WAS ND App status API.  See [APIs](https://github.com/kappnav/design/blob/master/APIs.md) for further details. 

The following diagram depicts the interaction: 

![controller](https://github.com/kappnav/design/blob/master/images/controller-architecture.png)
 

### WAS-Traditional-App Discovery 

WAS-Traditional-App resources are created automatically by Prism through a discovery process. This process occurs 
automatically through the operation of a Kubernetes controller, referred to as the 'WAS ND Controller'. The WAS ND Controller
periodically polls each defined WAS-ND-cell resource to obtain the current list of applications and their current operational 
status. The polling interval duration is defined in the WAS-ND-cell resource itself. 

Each time the WAS ND Controller obtains the current application list from a WAS ND cell, it synchronizes that list with the 
current list of WAS-Traditional-App resources in the current Kubernetes cluster.  It also synchronizes the [prism status annotation](https://github.com/kappnav/design/blob/master/status-determination.md#prism-status-representation-and-storage) for each WAS-Traditional-App.

The WAS ND Controller also observes the lifecycle of WAS-ND-cell resources.  When a new WAS-ND-cell resource is created, the 
WAS ND Controller starts polling that WAS ND cell, as described in the previous paragraph.  When a WAS-ND-cell is deleted, 
the WAS ND Controller deletes all WAS-Traditional-App resources belonging to that WAS ND cell. 

### WAS ND Cell and WAS Traditional App User Experience 

The general idea is for the user to define a WAS-ND-cell resource and then the controller creates the WAS-Traditional-App resources and keeps them in synch with the cell. 

The WAS-ND-cell can be created using a Kubernetes resource manifest (i.e. yaml or json file) via kubectl or helm, just like any other resource. A WAS-ND-Cell can also be created through the [WAS ND Cell view's Create] button(https://github.com/kappnav/design/blob/master/was-cell-ui.md#create-was-nd-cell-button).

## Liberty-Collective

Liberty collectives are represented in Kubernetes by a Custom Resource Definition. A Liberty-Collective resource holds the network endpoint for a Liberty collective. The Liberty-Collective resource is referenced by Liberty-App resources that are installed in the referenced collectives.  Liberty-Collective resources must be created in the prism namespace. 

Liberty-Collective Schema

```
apiVersion: prism.io/v1beta1
kind: Liberty-Collective 
metadata: 
  name: <collective name>
  namespace: prism 
spec:
    host: <host-name>
    https_port: <port-number>
    console_uri: <console-uri>
    interval: <seconds>
status:
    value: ONLINE | OFFLINE 
```

Where: 

| Field | Description | 
|:------|:------------|
| host | Specifies the host name (or ip address) of a collective controller. This is a required value. | 
| https_port | Specifies the port number by which to access the admin center for this collective. This is a required value.
| console_uri | Specifies the uri portion of the admin console URL - i.e. 'console-uri' in the following pattern: https://${host}:${https_port}/${console-uri}. It is an optional specification. The default is 'adminCenter'.|
| interval | Specifies in seconds the amount of time between calls to the dmgr to determine the status of the associated (actual) WAS ND application. This is an optional value.  The default is 30 seconds. | 
| status | Describes status of the Liberty-Collective resource.  A value of ONLINE means the collective is accessible over the network.  A value of OFFLINE means it is not. | 

Example: 

```
apiVersion: prism.io/v1beta1
kind: Liberty-Collective 
metadata: 
    name: collective1
    namespace: prism 
spec:
  host: "9.57.4.23"
  https_port: 9443

```


## Liberty-App

The Liberty-App represents a J2EE application, deployed on a standalone Liberty application server. Its primary purpose is to represent an Liberty app as part of an overall application, as defined by [Application CRD](#application-crd), above. 

Liberty-App Schema

```
apiVersion: prism.io/v1beta1
kind: Liberty-App
metadata: 
  name: <app-name>
  annotations: 
    prism.platform.kind: Liberty-Collective
    prism.platform.name: <collective-name> 
```

Where: 

| Field | Description | 
|:------|:------------|
| prism.platform.kind | Specifies the platform kind is Liberty-Collective. This is a required value. | 
| prism.platform.name | Specifies the name of the Liberty-Collective on which this instance is deployed. This is a required value.| 


Note: annotations are used where fields could clearly be used instead.  This is for consistency with all other resources, which can only use annotations to store platform info. 

Example: 

```
apiVersion: prism.io/v1beta1
kind: Liberty-App
metadata: 
    name: messaging 
    annotations: 
    prism.platform.kind: VM
    prism.platform.name: prod.server1.corpx.com  
```

### Liberty App Action Config Map 

Liberty Apps are configured out of the box to support the following actions: 

1. edit Liberty App Kubernetes resource 
1. login to admin center  
1. view Kibana log for this Liberty App 

Definition: 

```
apiVersion:  v1
kind: ConfigMap
metadata: 
  name: prism.actions.was-liberty-app
  namespace: prism 
data:
  url-actions: | 
      [
        {  
          "name": "edit", 
          "description": "Edit", 
          "url-pattern": "https://${global.builtin#icp_console_url}/prism/was_traditional_app/${resource.metadata.namespace}/${resource.metadata.name}"
        },
        {  
          "name": "dmgr", 
          "description": "Login to Dmgr", 
          "url-pattern": "https://${resource.annotations[prism.platform.name]}:${resource.spec.https-port}/ibm/admincenter" 
        },
        {  
          "name": "logs", 
          "description": "View Kibana Logs", 
          "url-pattern": "https://${global.builtin#kibana_url}/${global.builtin#liberty_log_dashboard}" *** TODO: finish ***
        }
      ]    
```

### Liberty-App Status Values 

Liberty-App resources represent a Java EE application running on a standalone Liberty application server. All Kubernetes resources have a status value. A mapping is used between the status of the Java EE application and the corresponding Liberty-App resource to establish the status values of the Kubernetes resource.  

The following mapping is used: 

| Java EE Application Status | Liberty-App Resource Status | 
|:---------------------------|:---------------------------|
| Application started | Started|
| Application stopped | Stopped | 
| Application server starting, stopping, stopped | Stopped | 
| Unknown | Unknown | 

Java EE application status is unknown when any error occurs while attempting to retrieve application server or application status. 

### Liberty Controller 

The Liberty App Controller is a standard Kubernetes controller for the Liberty-App custom resource type.  It's primary purpose is to maintain the status of the Liberty-App resource instances. It does this by periodically querying the Liberty server on which the Liberty app represented by the Liberty-App resides, and evaluating status of the Liberty App to reflect that accordingly in the status field of the corresponding Liberty-App resource instance. 

The Liberty App Controller is implemented in Go, as are all Kubernetes controllers, and delegates most of its function to the Liberty App status API.  See [APIs](https://github.com/kappnav/design/blob/master/APIs.md) for further details. 

The following diagram depicts the interaction: 

![controller](https://github.com/kappnav/design/blob/master/images/controller-architecture-liberty.png)


## Prism API Server

The Prism API Server exposes several APIs useful to WAS ND App integration: 

### Application CRUD API 

1. create Application 

   PUT https://{host}:{port}/prism/application

   Input JSON: valid Kubernetes Application. 
   
1. retrieve Application 

   GET https://{host}:{port}/prism/application/\<application name\>[?namespace=\<namespace\>]

   Output JSON: valid Kubernetes Application. 
   
1. update Application

   POST https://{host}:{port}/prism/application

   Input JSON: valid Kubernetes Application. 
   
1. delete Application

   DEL https://{host}:{port}/prism/application/\<application name\>[?namespace=\<namespace\>]
   
### ConfigMap CRUD API 

1. create ConfigMap 

   PUT https://{host}:{port}/prism/configmap

   Input JSON: valid Kubernetes ConfigMap. 
   
1. retrieve ConfigMap 

   GET https://{host}:{port}/prism/configmap/\<configmap name\>[?namespace=\<namespace\>]

   Output JSON: valid Kubernetes ConfigMap. 
   
1. update ConfigMap 

   POST https://{host}:{port}/prism/configmap

   Input JSON: valid Kubernetes ConfigMap. 
   
1. delete ConfigMap

   DEL https://{host}:{port}/prism/configmap/\<configmap name\>[?namespace=\<namespace\>]
   
### Secret CRUD API 

1. create Secret 

   PUT https://{host}:{port}/prism/secret

   Input JSON: valid Kubernetes Secret. 
   
1. retrieve Secret

   GET https://{host}:{port}/prism/secret/\<secret name\>[?namespace=\<namespace\>]

   Output JSON: valid Kubernetes Secret. 
   
1. update Secret

   POST https://{host}:{port}/prism/secret

   Input JSON: valid Kubernetes Secret. 
   
1. delete Secret

   DEL https://{host}:{port}/prism/secret/\<secret name\>[?namespace=\<namespace\>]
   
### WAS-Traditional-App CRUD API 

1. create WAS-Traditional-App 

   PUT https://{host}:{port}/prism/wasndapp

   Input JSON: valid Kubernetes WAS-Traditional-App. 

1. retrieve WAS-Traditional-App 

   GET https://{host}:{port}/prism/wasndapp/\<WAS-Traditional-App name\>[?namespace=\<namespace\>]

   Output JSON: valid Kubernetes WAS-Traditional-App. 
   
   Convenience API for status: 
   
   GET https://{host}:{port}/prism/wasndapp/\<WAS-Traditional-App name\>/status[?namespace=\<namespace\>]

   {status: \<status value\>

1. update WAS-Traditional-App 

   POST https://{host}:{port}/prism/wasndapp

   Input JSON: valid Kubernetes WAS-Traditional-App. 

1. delete WAS-Traditional-App

   DEL https://{host}:{port}/prism/wasndapp/\<WAS-ND-Cell name\>[?namespace=\<namespace\>]
   
### WAS-ND-Cell CRUD API 

1. list WAS-ND-Cells

   GET https://{host}:{port}/prism/wasndcells
   
   Output JSON: 
   ```
   { 
      "cells": { [ 
           { 
              "cell": {<WAS-ND-Cell JSON>},
              "action-map": {<action config map JSON>
           },
           etc
      ] }
   }   
   ```

1. create WAS-ND-Cell 

   PUT https://{host}:{port}/prism/wasndcell

   Input JSON: valid Kubernetes WAS-ND-Cell. 

1. retrieve WAS-ND-Cell

   GET https://{host}:{port}/prism/wasndcell/\<WAS-ND-Cell name\>[?namespace=\<namespace\>]

   Output JSON: valid Kubernetes WAS-ND-Cell. 
   
1. update WAS-ND-Cell

   POST https://{host}:{port}/prism/wasndcell

   Input JSON: valid Kubernetes WAS-ND-Cell. 

1. delete WAS-ND-Cell

   DEL https://{host}:{port}/prism/wasndcell/\<WAS-ND-Cell name\>[?namespace=\<namespace\>]


### Liberty-App CRUD API 

1. create Liberty-App 

   PUT https://{host}:{port}/prism/libertyapp

   Input JSON: valid Kubernetes Liberty-App. 

1. retrieve Liberty-App 

   GET https://{host}:{port}/prism/libertyapp/\<Liberty-App name\>[?namespace=\<namespace\>]

   Output JSON: valid Kubernetes Liberty-App. 
   
   Convenience API for status: 
   
   GET https://{host}:{port}/prism/libertyapp/\<Liberty-App name\>/status[?namespace=\<namespace\>]

   {status: \<status value\>

1. update Liberty-App 

   POST https://{host}:{port}/prism/libertyapp

   Input JSON: valid Kubernetes WAS-Traditional-App. 

1. delete WAS-Traditional-App

   DEL https://{host}:{port}/prism/wasndapp/\<WAS-ND-Cell name\>[?namespace=\<namespace\>]
   
### Liberty-Collective CRUD API 

1. list Liberty-Collective

   GET https://{host}:{port}/prism/libertycollective
   
   Output JSON: 
   ```
   { 
      "collectives": { [ 
           { 
              "collective": {<Liberty-Collective JSON>},
              "action-map": {<action config map JSON>
           },
           etc
      ] }
   }   
   ```

1. create Liberty-Collective

   PUT https://{host}:{port}/prism/libertycollective

   Input JSON: valid Kubernetes Liberty-Collective. 

1. retrieve Liberty-Collective

   GET https://{host}:{port}/prism/libertycollective/\<Liberty-Collective name\>[?namespace=\<namespace\>]

   Output JSON: valid Kubernetes Liberty-Collective. 
   
1. update Liberty-Collective

   POST https://{host}:{port}/prism/libertycollective

   Input JSON: valid Kubernetes Liberty-Collective. 

1. delete Liberty-Collective

   DEL https://{host}:{port}/prism/libertycollective/\<Liberty-Collective name\>[?namespace=\<namespace\>]

