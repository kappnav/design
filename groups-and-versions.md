The [Kubernetes Applications SIG](https://github.com/kubernetes-sigs/application) defines the Application CRD for defining Kubernetes applications consisting of multiple resources, known as components.

The specification defines a spec field `componentKinds` which is an array of the components of an application.

```yaml
spec:
  componentKinds:
    - group: core
      kind: Service
    - group: apps
      kind: Deployment
```

Only `group` and `kind` are currently defined for an application component. 
<br/><br/>

**Invalid group names and backward compatibility**

Initial implementations of Application Navigator allowed invalid values to be specified for group which could cause errors when multiple CRDs have the same kind but different groups.

* ***Backward Compatible Kinds***

    When an invalid group is specified for any of the following kinds the group and version in the table will be used:
    
    | Kind | Group | Version |
    | --- | --- | --- |
    | Application | app.k8s.io | v1beta1 |
    | ClusterRole | rbac.authorization.k8s.io | v1 |
    | ClusterRoleBinding  | rbac.authorization.k8s.io | v1 |
    | ConfigMap |   | v1 |
    | CustomResourceDefinition | apiextensions.k8s.io | v1beta1 |
    | Deployment | apps | v1 |
    | Endpoint |   | v1 |
    | Ingress | extensions | v1beta1 |
    | Job | batch | v1 |
    | Node |   | v1 |
    | PersistentVolumeClaim |  | v1 |
    | Role | rbac.authorization.k8s.io | v1 |
    | RoleBinding | rbac.authorization.k8s.io | v1 |
    | Route | route.openshift.io | v1 |
    | Secret |   | v1 |
    | Service |  | v1 |
    | ServiceAccount |   | v1 |
    | StatefulSet | apps | v1 |
    | StorageClass | storage.k8s.io | v1 |
    | Volume |   | v1 |
<br/>

**Special group name "core"**

The `group:` value `core` is used to specify kinds that are built in to Kubernetes. These core builtin kinds have a blank/empty group  internally. 
```yaml
    - group: core
      kind: Service
```
<br/>

**Versions**

The version for each group/kind will be the preferred version for the group, as determined by Kubernetes discovery, since the spec does not provide a way to specify version.  
