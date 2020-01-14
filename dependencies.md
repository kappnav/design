# Handling Dependencies 


NOTE (27 FEB 2019) - the dependencies model is not presently scheduled for implementation.  We will keep the design information and re-evaluate the need at a future point in time. 

The person defining an application (application owner) may know which services directly comprise the application, but
may not know what dependencies those services may have.  Consider the following diagram: 

![assembly-1](https://github.com/kappnav/design/blob/master/images/assembly-1.png)

The application owner may well know that service s1 is part application 1,  but may have no idea that service s1 depends 
on service s3.  The owner of service s1 certainly knows this.  

Similarly, the owner of service s1 may have no idea that service s3 depends on service s4.  But the owner of serviced s3 must 
certainly know this. 

It is clear that the operational health of application 1 is influenced by the health of services s1, s3, and s4.  

## Localizing Dependency Knowledge 

Since the application owner may or may not know what dependencies the services that comprise the application possess, it is unreasonable to expect the application owner to be able to specify the entire dependency chain. Moreover, it is not reasonable to expect a service owner to label their service in such a way that their service will be included in an application view unknown to the application owner.  E.g.

- application label selector specifies 'app=application-1'
- service label specifies 'app-application-1'

The service would in this manner have to add a label for each application that uses it.  That may be unrealistic in many cases - especially in the case of a shared service (see [shared services](https://github.com/kappnav/design/blob/master/shared-services.md) for more), where the shared service owner really has no practical way knowing which other services are making use of the shared service. 

A more natural approach would be for a service owner to specify a label selector on the service itself, which identifies the service's direct dependencies. The dependencies could do this, in turn, and thereby establish the full dependency hierarchy.  Since potentially any Kubernetes Kind could be part of an application, these selectors could be specified as an annotation.   

Example: 

![dependency-1](https://github.com/kappnav/design/blob/master/images/dependency-1.png)

Combining the label selectors on the applications plus the label selectors on the service annotations, we'd have the following progression for application 1: 

1. label selector in application 1 selects services s1 and s2
1. label selector in service s1 selects service s3 
1. label selector in service s3 selects service s4

The same progression would apply similarly to application 2.  The resulting application view would look like this: 

![dependency-2](https://github.com/kappnav/design/blob/master/images/dependency-2.png)
