# Integration with Openshift "partof" Label

Redhat Openshift provides an application composition model based on the 'app.kubernetes.io/part-of' label. The label specifies
the name of an application. The model is straight-forward: resources in the same namespace, with the same application name, 
are part of the same application.  

The Openshift console's developer mode has a topology view that enables the user to assign application names to resources and
visualize the composition.  The composition is limited to Deployment, DeploymentConfig, and StatefulSet kinds.  

Application Navigator will watch for resources with this 
