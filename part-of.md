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
| neither auto-create, <br> nor part-of | n/a | n/a | no application CR is created | 
| auto-create | true | auto-create.name=app1 | application CR "app1" is created | 
| part-of | app2 | n/a | application CR "app2" is created | 
| auto-create <br> part-of | true <br> app2 | auto-create.name=app1 <br> n/a | application CR's "app1" and "app2" are created |
| auto-create <br> part-of | true <br> app1 | auto-create.name=app1 <br> n/a | application CR "app1" is created |

# Auto-deletion

Same as the auto-create support:  when last top-level resource in the same namespace specifying the same part-of value is deleted, the auto-created application CR is deleted. 

# Future Top Level Kinds 

The following configuration in the kappnav CR controls which top level kinds support auto-create and part-of labels with default shown: 

```
apiVersion: kappnav.operator.kappnav.io/v1
kind: Kappnav
metadata: 
   name: kappnav
spec: 
   auto-create-kinds: 
      - group: apps
        version: v1
        resource: deployments
      - group: apps
        version: v1
        resource: statefulsets 
```
