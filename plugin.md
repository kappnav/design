# Application Navigator Plugin Interface 

The Application Navigator Plugin Interface enables users to extend the capabilities of Application Navigator. The 
plugin interface allows the following extension types: 

1. action

   The action extension type supports day 2 operations. These are things an administrator may need to do to a running application for any number of purposes, including inspection, gathering diagnostic data, changing configuration,  etc.. 

1. status 

   The status extension type provides a way to customize how resource status is mapped to Application Navigator's uniform high level status indicators of:  normal, warning, problem, and unknown.  

1. detail

   The detail extension type provides a way to enhance the view of an application or application component with additional information. 

## Action Extension Type 

The action extension type supports day 2 operations. These are things an administrator may need to do to a running application for any number of purposes, including inspection, gathering diagnostic data, changing configuration,  etc.. 

All Application Navigator actions are exposed as actions in an actions menu for each application or application component.  

There are two kinds of actions: 

1. Web action

   Web actions associate a URL with a resource. "Performing" the action means opening the URL. 

1. Command action

   Command actions associate a container image with a resource.  The purpose of the container is to run a command.  Command actions run as Kuberentes jobs. "Performing" the action means running the job.  User inputs to provide parameters to the command are supported. 

Actions are defined in a Config Map.  The Config Maps consumed by Application Navigator are defined by a "Kind Action Mapping" custom resource.  The mappings allow specific actions to be assigned to specific resource kinds or instances.  Therefore, creating an Application Navigator action requires two steps: 

1. [Create action config map resource.](https://github.com/kappnav/design/blob/master/actions-config-maps.md)
1. [Create kind action mapping resource.](https://github.com/kappnav/design/blob/master/kind-action-mapping.md)

See also [Implementing Custom Actions](https://github.com/kappnav/apis/tree/master/tools/actdev#action-developer-tool-actdev)

## Status Extension Type 

The status extension type provides a way to customize how resource status is mapped to Application Navigator's uniform high level status indicators of:  normal, warning, problem, and unknown. This applies equally to Custom Resources. 

A small number of built-in resource kinds have out-of-the-box status mappings. These kinds include Deployment, Pod, and Route; these can be customized according to user preference.  Most other resource kinds are covered by a default mapping that essentially equates 'existence' with 'normal' status; any of these can be given a specific mapping according to user preference. 

Status mappings are defined in a Config Map.  These mapping rules map a resource's unique status values to the Appliction Navigator's status scheme.  Status mappings are defined for a discrete resource kind. They are assigned to a resource kind through the "Kind Action Mapping" custom resource.  Creating a status mapping requires two steps: 

1. [Create status mapping config map resource.](https://github.com/kappnav/design/blob/master/status-determination.md)
1. [Create kind action mapping resource.](https://github.com/kappnav/design/blob/master/kind-action-mapping.md)

## Detail Section Extension Type 

The detail section extension type provides a way to enhance the view of an application or application component with additional information displayed in a detail section in the App Navigator UI. A detail section is displayed in the App Navigator UI as an expandable area on the bottom edge of an application or component row. Clicking on a special icon opens and closes the detail section.

A detail section is assigned on a per kind basis.  It is defined in a config map.  They are assigned to a resource kind through the "Kind Action Mapping" custom resource.  It specifies details about the layout of 
the detail section and the source of information to be displayed in that section. Creating a detail section requires two steps:


1. [Create detail section config map resource.](https://github.com/kappnav/design/blob/master/ui-detail-sections.md)
1. [Create kind action mapping resource.](https://github.com/kappnav/design/blob/master/kind-action-mapping.md)
