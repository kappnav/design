# Namespace Support 

Prism must be installable into an arbitrary namespace of the user's choice.  This affects all elements:  deployments, 
configmaps, ingress, etc..

This means multiple instances of App Navigator may run on the same Kubernetes cluster at the same time.  

## Application Namespaces 

By default, the components of an application are in the same namespace as the application.  This means an application's label 
selector is applied only to the specified component kinds in the same namespace of the application.  

Components from other namespaces can be included in the label selector search by listing them comma-delimited on the prism.component.namespaces
annotation.  This annotation is supported only in the Application custom resource kind. 

Example: 

```
prism.component.namespaces: "namespace1, namespace2" 
```

Specifies to apply the application's label selector to namespaces 'namespace1' and 'namespace2' in addition to the application's own namespace. 


The annotation is optional.  If not specified, no additional namespaces are applied to the label selector - only the application's own namespace is used. 

## Application Navigator Application Namespaces (Frontier) 

When multiple App Navigator instances are installed on the same cluster, they can be isolated from one another by constraining 
the namespaces in which a given instance can search for applications.  This is colloquially called a 'namespace frontier'. 

This setting is specified in the prism.config configmap: 

```
app-namespaces= "namespace1, namespace2, ..." 
```

The comma-delimited list of namespaces specified in the app-namespaces setting gives the set of namespaces in which App Navigator will search for applications. By default, all namespaces are searched for applications. 

Default is specified in the config map as an empty (zero length) string: 

app-namespaces: ""

Example: 

If AppNav instance 1 (aka AppNav1) has prism.config value setting: 

```
app-namespaces= "namespace1a, namespace1b" 
```

and 

AppNav instance 2 (aka AppNav2) has prism.config value setting:

```
app-namespaces= "namespace2a, namespace2b" 
```

Then AppNav1's namespace frontier would be namespace1a and namespace1b, while 
AppNav2's would be namespace2a and namespace2b.  The result would be that AppNav1 shows only application from its frontier and AppNav2 from its frontier. 

It follows that namespaces specified by an Application's prism.component.namespaces annotation should be a subset of 
those given by the app-namespaces setting (or its default). 

Therefore, the implementation must ignore namespaces specified in a prism.component.namespaces annotation that are not
also included in the app-namespaces setting (or its default).  An warning message must be issued.

Both the controller and the WASController must implement frontiers.  Only the controller must implement the above warning messages, since twas-apps/twas-cells and liberty-apps/liberty-collectives are always in the same namespace as one another. 

## tWAS-Cells and Liberty-Collectives

The WASController also obeys the app-namespaces setting from the prism.config config map.  It searches and monitors only tWAS-Cell and Liberty-Collective instances that are in the namespace list given by the app-namespaces setting.
