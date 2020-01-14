# Shared Services

NOTE (27 FEB 2019) - the shared services model is not presently scheduled for implementation.  We will keep the design information and re-evaluate the need at a future point in time. 

Shared services present a unique challenge to application composition based on label selectors.  The following diagram depicts
two applications using a shared service.  The shared service, in turn, depends on an additional service: 

![assembly-1](https://github.com/kappnav/design/blob/master/images/assembly-1.png)

If we create two applications and label all resources, we might have the following: 

![assembly-2](https://github.com/kappnav/design/blob/master/images/assembly-2.png)

These definitions would enable the following application navigation and status.  Note service s4's yellow status is not
reflected in the application views: 

![assembly-3](https://github.com/kappnav/design/blob/master/images/assembly-3.png)

If we introduce the concept of an 'application assembly', we then have a way to represent a shared service and its dependencies: 

![assembly-4](https://github.com/kappnav/design/blob/master/images/assembly-4.png)

If we then add an assembly definition for use by our applications and label things a big differently, we might have: 

![assembly-5](https://github.com/kappnav/design/blob/master/images/assembly-5.png)

This would result in the following application navigation and status, which does factor in the status of service s4: 

![assembly-6](https://github.com/kappnav/design/blob/master/images/assembly-6.png)
