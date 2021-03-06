# Action Enablement and Resource Capabilities 

kAppNav allows day 2 operations to be defined as menu items on action menus in the kAppNav UI.  
These actions can be defined for kubernetes kinds, subkinds, and individual resource instances. 
See [actions](https://github.com/kappnav/design/blob/master/actions-config-maps.md)
for detailed design. 

When an action is defined for a kind, it causes the action to be displayed on the UI menu for every instance of that kind. 
However, not all instances of the kind can necessarily support (i.e. perform) the action: some of these kind-scoped actions 
depend on certain optional features being available in the target resource, which the target resource may or may not possess.

For example: 

| Action | Resource | Dependency (required capability) |
|--------|----------|------------|
| Open Admin Center | Deployment.Liberty | Liberty image configured with admin-center feature. | 
| View mp1.0 Metrics | Deployment.Liberty | Liberty image configured with mp1.1 feature. | 
| View mp2.0 Metrics | Deployment.Liberty | Liberty image configured with mp2.0 feature. | 
| View App Metrics | Deployment.Nodejs | Node.js image includes ('requires') appmetrics package. | 
| View Git Repo | Various | Appsody originated resource has org.opencontainers.image.url label | 

Since resources have no explicit way to identify their supported capabilities, kAppNav will utilize labels as a means to 
'expose', so to speak, capabilities.  If a resource exposes a capability on which a particular action depends, that action 
will be revealed to the user on the corresponding UI menu; otherwise it will not. 

The new field supported on url-action and cmd-action definitions is named 'enablement-label'.  Specification: 

```
        {  
          "name": "<name>", 
          "text": "<text for menu item>", 
          "description": "<brief description>", 
          "url-pattern": "<substitution-pattern>",
          "open-window": "current" | "tab" | "new ",
          "menu-item": "true" | "false",
          "requires-input": "<input-name>",
          "enablement-label":"<label-name>"
        }
```

| Field | Description |
|-------|-------------|
| enablement-label | Specifies the name of a resource label.  This action will be displayed in the UI 
action menu for an instance of this resource if and only if the resource possesses the specified label. This 
field is optional. If not specified, the action will be displayed in the UI action unconditionally for the 
target resource. | 

## Implementation

Action definitions will specify the name of the label. If specified, a target resource must have that label in order to 
'enable' that action for display on the UI action menu for that resource.  If an action has no enablement label, it is considered 'enabled' by default. The UI will filter out these actions to display only those that are enabled.  

E.g. 

```
apiVersion: v1
kind: ConfigMap
metadata:
  name: kappnav.actions.deployment-liberty
  namespace: kappnav
data:
  url-actions: |
    [   
      {
        "name":"metrics-mp11",
        "text":"View 1.1 Metrics",
        "description":"View Liberty mp1.0 metrics in Grafana dashboard",
        "url-pattern":"${builtin.grafana-url}/d/websphere-liberty/liberty-Metrics-G5-20190521?refresh=10s&orgId=1&var-app=${resource.$.metadata.name}",
        "open-window": "tab",
        "enablement-label":"kappnav.action.metrics.mp11"
      },
      {
        "name":"appsody-gitrepo",
        "text":"View Source in Git Repo",
        "description":"View source code in git repo",
        "url-pattern":"${resource.$.metadata.labels['org.opencontainers.image.url']}",
        "open-window": "tab",
        "enablement-label":"dev.appsody.application"
      }
    ]
      
```

So for a Liberty deployment (sub) kind , the two actions above would be displayed in the action menu for a liberty deployment
if and only if the deployment resource has these labels: 

```
labels:
     liberty.feature.mp11: installed 
     dev.appsody.application: mobile-cart 
```

Each action is considered separately, so it's possible to enable one and not the other.  E.g. the liberty resource could 
one label and not the other, or not labels at all, etc..

The value of the label does not matter.  It's the fact that the label is specified on the resource, regardless of value, that
matters.  The criteria is that if the action definition specifies an enablement label, then the resource must have that label
in order to "enable" the action.  The value of the label does not matter. 

# Defined Labels  

|+ Action                    | Kind[.subkind]           | Enablement Label                    |
|---------------------------|--------------------------|-------------------------------------|
| View 1.1 Metrics          | Deployment.Liberty       | kappnav.action.metrics.mp11         | 
| View 2.0 Metrics          | Deployment.Liberty       | kappnav.action.metrics.mp20         | 
| View App Metrics          | Deployment.Nodejs        | kappnav.action.appmetrics           | 
| View Project Doc          | Deployment               | stack.appsody.dev/id                |
| View Project Source       | Deployment               | stack.appsody.dev/id                |
| View Project Doc          | Service                  | stack.appsody.dev/id                |
| View Project Source       | Service                  | stack.appsody.dev/id                |
| View Collection Doc       | Deployment               | stack.appsody.dev/id                |
| View Collection Source    | Deployment               | stack.appsody.dev/id                |
| View Collection Doc       | Service                  | stack.appsody.dev/id                |
| View Collection Source    | Service                  | stack.appsody.dev/id                |
| Appsody Detail Section    | Deployment               | stack.appsody.dev/id                |  
| Appsody Detail Section    | Service                  | stack.appsody.dev/id                |  
