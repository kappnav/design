# The KUBE_ENV Environment Variable

The KUBE_ENV environment variable is set by the AppNav Helm Chart, and therefore by the AppNav Helm Operator.  

Values:

1. icp - means IBM Cloud Private
1. minikube - means, well, minikube
1. minishift - means minishift
1. okd - means Origin Community Distribution (i.e. OpenShift open source) 
1. ocp - means OpenShift Cloud Platform (i.e. commercial OpenShift) 

Usage:

e.g. shell script

```
if [ x$KUBE_ENV = xokd ]; then 
  echo set to value okd
else 
  echo not set to okd 
fi
```

Note: this value is also available during Helm chart template processing (and therefore also works in the AppNav Helm Operator).  The values.yaml name is kubeEnv.  

Example test: 

```
{{ if eq .Values.env.kubeEnv "minikube" }}

{{ else }}

{{ end }}
```
