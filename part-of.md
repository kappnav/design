# Integration with RHOCP Application Grouping

RHOCP's application grouping mechanism is based entirely on assigning the apps.kubernetes.io/part-of label to a "top level" 
resource.  As of RHOCP version 4.3, these top-level resources are Deployment and StatefulSet kinds. Additional top level kinds
may be introduced in the future. 

The goal of this integration is to reflect the RHOCP application grouping in App Navigator's application view. This will be 
done by treating top level resources that possess the "part-of" label the same as top level resources that possess the 
["kappnav-auto-create" label](https://github.com/kappnav/design/blob/master/auto-app-lifecycle.md).  

Resources that posess the part-of label will implicitly auto-create an application CR with the following spec: 

```
labels: 
    kappnav.app.auto-create: true

annotations:
    kappnav.app.auto-create.name: {value of part-of label}
    kappnav.app.auto-create.kinds: "apps/Deployment", "apps/StatefulSet" 
    kappnav.app.auto-create.version: 1.0.0
    kappnav.app.auto-create.label: “apps.kubernetes.io/part-of"
    kappnav.app.auto-create.labels-values: {value of part-of label}
```

# Special cases

With this support, now a top level resource (e.g. Deployment) has two ways to cause an Application CR to be automatically
created: through either the kappnav-auto-create label or the apps.kubernetes.io/part-of label. 

An application may be created with these combinations:

| label | label value | other settings | outcome |  
|:--------|:-------------|:----------------|:---------|
| none | n/a | n/a | no application CR created | 
| auto-create | true | auto-create.name=app1 | application CR "app1" is created | 
| part-of | app2 | n/a | application CR "app2" is created | 
| <ul style="list-style-type:none;"> <li>auto-create</li> <li>part-of</li> <eul> |  <ul style="list-style-type:none;"> <li>true</li> <li>app2</li> <eul> | <ul style="list-style-type:none;"> <li>auto-create.name=app1</li> <li>n/a</li> <eul> | application CR's "app1" and "app2" are created | 

