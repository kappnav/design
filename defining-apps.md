# Defining Applications 

We previously introduced the concept of 
[big 'A' applications](https://github.com/kappnav/design/blob/master/README.md#project-prism), and by
implication, little 'a' applications, which are individual components of the big 'A' application - e.g. a discrete microservice,
or web app, etc, are examples of little 'a' applications. 

Some might prefer to call a big 'A' application something else to reduce ambiguity with little 'a' 
applications - e.g. 'solution'.  That might be done for conversational or representational convenience. However, the 
Custom Resource Definition representing big 'A' applications is defined by the [Kubernetes Application SIG](https://github.com/kubernetes-sigs/application), and its Kubernetes 
resource kind is 'Application'.  For the purpose of this section,  'Application' will designate big 'A' application
and 'app' will designate little 'a' application.  We will also use the terms 'solution' and 'component' as a synonyms for 
'Application' and 'app', respectively, when added clarity is desired. 

## Mechanics of Defining Applications

In Kubernetes, an Application is defined as a resource instance and its components are determined dynamically via a label 
selector. An Application further qualifies which Kubernetes resource kinds may be selected as components by the label selector.

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

**Important**:  label selectors match only labels defined under a resource's metadata section - e.g.

```
metadata:
   name: someResourceInstance
   labels: 
      app: theComponentName
```

## Strategy of Defining Applications

There are basically two strategies: 

1. Single deployment 

   Deploy all Application components and the Application itself in a single deployment (e.g. single Helm chart).  

1. Multiple deployments 

   Deploy individual Application components, each as a separate deployment (e.g. one Helm chart per component), and deploy the Application itself as either a separate deployment (e.g. its own Helm chart) or designate one of the components as the logical 'main' component of the Application and deploy the Application resource as part of the 'main' component's deployment - i.e. put the Application resource in the same deployment (e.g. Helm chart) as the 'main' component. 
   
## Best Practices of Defining Applications

There are lots of ways to organize components into Applications. Best practices are simple and few: 

1. Pick a label name to use to identify resources that comprise a component and use that label consistently. 

   This label should be added to each resource (e.g. Deployment, Service, etc) that comprises the component and done so at developement time. Ideally tools, like Micro Climate, would do this automatically.  A pre-existing convention found across many Kubernetes examples is to use the label name 'app' to identify the resources that are part of the same component. 

1. Pick a label name to use to identify resources that comprise an Application and use that label consistently. 

   This label should also be added to each resource (e.g. Deployment, Service, etc) that comprises the Application and also done so at development time.  Again, tools like Micro Climate could help the user assign these labels.  Because of the prevalence of the label 'app' to designate component membership, and the fact that label names must be lower case, we cannot use 'Application' as a label name to designate the components that comprise an application.  Therefore, the label 'solution' is recommended to clearly distinguish itself from the 'app' label.
   
1. Put label definitions in your source files (e.g. Helm chart yamls) and store them in your source control system (e.g. github).  
   
Some examples: 

```
kind: Deployment
metadata: 
   name: trader-deployment
   labels:
      app: trader
      solution: stock-trader
      
kind: Service
metadata: 
   name: trader-service
   labels:
      app: trader
      solution: stock-trader
 
 kind: Deployment
metadata: 
   name: portfolio-deployment
   labels:
      app: portfolio
      solution: stock-trader
      
kind: Service
metadata: 
   name: portfolio-service
   labels:
      app: portfolio
      solution: stock-trader
```

The preceding definitions specify there are two components (apps): 

1. trader
1. portfolio

Each comprised of a Deployment/Service pair - i.e. 

1. trader is comprised of trader-deployment and trader-service
1. portfolio is comprised of portfolio-deployment and portfolio-service

The following Application defines solution stock-trader: 

```
kind: Application
metadata:
   name: stock-trader
spec:
  selector:
    matchLabels:
     solution: "stock-trader"
  componentKinds:
    - group: deployments
      kind: Deployment
    - group: services 
      kind: Services
```

The preceding Application would select the following resources as components: 

1. trader-deployment
1. trader-service
1. portfolio-deployment
1. portfolio-service

## Dynamically Adding a Component to an Application at Runtime

While it's a best practice to harden your labels in your deployment files (Kubernetes yamls), it is nevertheless possible to dynamically assign labels at runtime and therefore dynamically add new components to an Application at runtime.  You might want to do this as a temporary measure to add a component that was left out due to oversight. However, if the change is meant to be long lived, the original deployment files should be updated in the source control system. 

The following command adds resource quote-service to the stock-trader Application.  In this example, the stock-trader Application and its components are defined in the stock-trader namespace: 

```
kubectl label service quote-service solution=stock-trader -n stock-trader
```
