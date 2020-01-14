# Security

## Application Controller 

Requirement:  Prism must run on cluster that have RBAC enabled.  Therefore ... 

The Application Controller requires read/write access to all Kubernetes resources across all namespaces.  There, it will run with a default service account and a cluster role binding, binding it to the [cluster-admin](https://kubernetes.io/docs/reference/access-authn-authz/rbac/) cluster role,  which grants full access to all resources in the cluster.  

The following cluster role binding should achieve the desired result: 

```
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  labels:
    app: application-controller
  name: application-controller
  namespace: prism
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: default
  namespace: prism
```

# Notes 

Resources:

1. [ICP Security Roadmap](https://github.ibm.com/IBMPrivateCloud/roadmap/tree/master/feature-specs/security) - See especially
   1. [IAM Onboarding](https://github.ibm.com/IBMPrivateCloud/roadmap/blob/master/feature-specs/security/iam-onboarding.md)
   1. [ICP RBAC Spec](https://github.ibm.com/IBMPrivateCloud/roadmap/blob/master/feature-specs/security/security_rbac_spec.md)
   1. [IAM Developer Guide](https://github.ibm.com/IBMPrivateCloud/roadmap/blob/master/feature-specs/security/security_developer_spec.md)
   1. [Security API Doc](https://github.ibm.com/IBMPrivateCloud/roadmap/blob/master/feature-specs/security/security-services-apis.md)
1. [CAM IM Onboarding](https://ibm.box.com/s/1b5yoe2ewsmm8yjbajil7fkqi19o8ul9)
1. [CAM Login Flow](https://swimlanes.io/d/Sk8ICPa5W)
1. [CAM Onboarding Flow](https://swimlanes.io/d/ByRBd5C_7)

From Chunlong:

[ICp authentication service allows boarding of any applications.](https://github.ibm.com/IBMPrivateCloud/roadmap/blob/master/feature-specs/security/security_developer_spec.md#6-client-model-3-registration)

Security Architecture: 

![architecture](https://github.com/kappnav/design/blob/master/images/security-architecture.png)

