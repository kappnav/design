# Automatic Application Lifecycle

Application Navigator will automatically create and delete applications without the user having to take explicit action.  

## Automatic Application Create

AppNav will auto-create/delete an Application resource when a specially labeled/annotated Deployment is created.  

The Application controller will be responsible for auto-creating/deleting Application resources.  The Application controller will watch Deployment resource creation/deletion and take the following actions: 

When a Deployment or Statefulset is created that contains the following label and annotations, the controller will auto-create an Application resource:  

```
labels: 
    kappnav.app.auto-create: true | false 

annotations:
    kappnav.app.auto-create.name: "<app name>"
    kappnav.app.auto-create.kinds: | 
       kind1, kind2, etc
    kappnav.app.auto-create.version: <version>
    kappnav.app.auto-create.label: “<label-name>”
    kappnav.app.auto-create.labels-values: | 
       value1, value2, etc 
```

| Annotation |	Description |	Default |
|------------|--------------|-----------|
| kappnav.app.auto-create.name |  Specifies name of application resource to be auto-created. | Name defaults to associated Deployment or Statefulset name. | 
| kappnav.app.auto-create.kinds | Specifies a json array of resource kinds to be included in application component list. | Deployment, Statefulset, Service, Ingress, Configmap | 
| kappnav.app.auto-create.version	| Specifies version of application resource to be auto-created.	| 1.0.0 | 
| kappnav.app.auto-create.label |	Specifies label to be specified in application resource label selector. |	app |
| kappnav.app.auto-create.labels-values |	Specifies a json array of match values for auto-create label. | If one value is specified, the label selector is matchLabels.  If multiple values are specified, the label selector is matchExpression.  |	Name of associated Deployment or Statefulset. Default is same as associated Deployment or Statefulset name. |


### Example 1

```
kind: Deployment
metadata:
   name: portfolio
   namespace: default
   labels: 
      kappnav.app.auto-create: true

annotations:
    kappnav.app.auto-create.name: “portfolio”
    kappnav.app.auto-create.kinds: | 
       Deployment, Service, Ingress
    kappnav.app.auto-create.version: 1.0.0
    kappnav.app.auto-create.label: “app”
    kappnav.app.auto-create.labels-values: | 
       portfolio

Would produce: 

apiVersion: app.k8s.io/v1beta1
kind: Application
metadata:
  name: portfolio
  namespace: default 
  labels:
     app: portfolio <- Note this annotation is equivalent to ${kappnav.app.auto-create.label}: ${kappnav.app.auto-create.name}
     app.kubernetes.io/name: portfolio
     app.kubernetes.io/version:  1.0.0
     kappnav.app.auto-created: true <- Note used to find orphaned Applications
  annotations: 
     kappnav.app.auto-created.from.name: portfolio <- Note used to find orphaned Applications
     kappnav.app.auto-created.from.kind: Deployment <- Note used to find orphaned Applications
spec:
  selector:
    matchLabels:
        app: portfolio
  componentKinds:
    - group: app
      kind: Deployment
    - group: app
      kind: Service
    - group: app
      kind: Ingress
```

### Example 2

```
kind: Statefulset
metadata:
   name: trader 
   namespace: default
   labels:
      kappnav.app.auto-create: true

annotations:
    kappnav.app.auto-create.name: “stocktrader”
    kappnav.app.auto-create.kinds: | 
       [ “Deployment", "Service", "Ingress", "NetworkPolicy” ]
    kappnav.app.auto-create.version: 1.0.0
    kappnav.app.auto-create.label: “app”
    kappnav.app.auto-create.labels-values: | 
       [ “trader, portfolio, quote” ]

Note: the specifications for Deployments portfolio and quote might choose to specify 'kappnav.app.auto-create: false' in order to have a flat resource list, rather than nested applications. 

The preceding specification would produce: 

apiVersion: app.k8s.io/v1beta1
kind: Application
metadata:
  name: stocktrader 
  namespace: default 
  labels:
     app: stocktrader <- Note this annotation is equivalent to ${kappnav.app.auto-create.label}: ${kappnav.app.auto-create.name}
     app.kubernetes.io/name: stocktrader
     app.kubernetes.io/version:  1.0.0
     kappnav.app.auto-created: true <- Note used to find orphaned Applications
  annotations: 
     kappnav.app.auto-created.from.name: portfolio <- Note used to find orphaned Applications
     kappnav.app.auto-created.from.kind: Deployment <- Note used to find orphaned Applications
spec:
  selector:
     matchExpressions:
        - {key: app, operator: In, values: [trader, portfolio, quote]}
  componentKinds:
    - group: app
      kind: Deployment
    - group: app
      kind: Service
    - group: app
      kind: Ingress
```                 	


## Automatic Application Delete

Similarly, when such a Deployment or Stateful set is deleted,  the controller will auto-delete the associated Application resource.  


### Example 1

When this resource is deleted: 

```
kind: Deployment
metadata:
   name: portfolio
   namespace: default
   labels: 
      kappnav.app.auto-create: true
   annotations:
      kappnav.app.auto-create.name: “portfolio”
```

The Application Controller will take action equivalent to the following command:  

```
kubectl delete application portfolio -n default 
```

### Example 2 

When this resource is deleted:

```
kind: Statefulset 
metadata:
   name: trader 
   namespace: default
   labels: 
      kappnav.app.auto-create: true
   annotations:
      kappnav.app.auto-create.name: “stocktrader”
```

The Application Controller will take action equivalent to the following command:  

```
kubectl delete application stocktrader -n default
```

## Orphan Cleanup 

It is possible for the Deployment or Stateful set that triggers the auto-creation to be deleted while the Application Controller is down. 

To cleanup any orphaned auto-created Application resources,  the Application Controller will search for orphans during its initialization.  

Auto-created Applications have the following label and annotations to enable this cleanup: 

```
  labels: 
     kappnav.app.auto-created: true 
  annotations: 
     kappnav.app.auto-created.from.name: <name of Deployment or StatefulSet>
     kappnav.app.auto-created.from.kind: <Deployment | StatefulSet > 
```
