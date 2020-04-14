# Hidden Application

An application exist, but not be displayed in the Application Navigator application view, by setting this annotation:

```
annotation: 
   kappnav.application.hidden: "true"
```

The annotation affects only the Application Navigator application view.  Hidden applications are still visible through the k8s 
API and through the kubectl CLI. 

A hidden application can serve as a useful anchor for application-scope command actions. 
