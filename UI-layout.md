# Prism Top Level View 

The top level view shows the application resources in the Kubernetes cluster in which Prism is running. 

## Common View Controls 

The Prism top level view will have controls consistent with other list view pages in the ICP console, for example, as does the Deployment view: 

![common-page-top](https://github.com/kappnav/design/blob/master/images/common-screen-top.png)

## Application Table

The principle purpose of the Prism top level view is to show a list application resources. Like other resource views in the ICP console, applications will be displayed using a tabular presentation: 

![application-table-view](https://github.com/kappnav/design/blob/master/images/application-table-view.png)

Where:

- Status uses a color scheme to designate whether the application is running, stopped, etc. The rational for colors (instead of text) and color determination algorithm is described [here](https://github.com/kappnav/design/blob/master/status-determination.md).
- Name is the application name. Clicking it takes the user to the [Prism Component Level View](#prism-component-level-view).
- Namespace is the Kubernetes namespace in which the application resource exists. 
- Action is a clickable field that opens a menu of selectable actions. See [Standard Action Menu Items](#standard-action-menu-items) and [Configurable Action Menu Items](#configurable-action-menu-items) for explanation of the action items available on this menu. 

### Sortable Column Values 

Columns heads are clickable to toggle the sort between ascending and descending.  An up/down arrow (triangle, really), as is done in the rest of the ICP console, will be used to designate whether sort order is ascending (up arrow) or descending (down arrow).  e.g. 

![](https://github.com/kappnav/design/blob/master/images/clickable-column-head.png)

The sort rule for each column is: 

- Status is sortable according to [status precedence](https://github.com/kappnav/design/blob/master/status-determination.md#prism-status-value-determination-algorithm-for-application-resource) order.
- Name column is sortable following the rules for a standard alphanumeric sort. 
  The default sort is ascending alphanumeric. 
- Namespace is sortable following the rules for a standard alphanumeric sort. 
  The default sort is ascending alphanumeric.
- Action column is not sortable. 

### Standard Action Menu Items

Like all other ICP views that display Kubernetes resources, the Prism top level page will include the following pre-defined action menu items: 

1. Edit 

The edit menu item, will launch a modal dialog to edit the Application's configuration, as is down elsewhere in the ICP console, as shown here with Deployment, as an example: 

![](https://github.com/kappnav/design/blob/master/images/resource-edit-modal.png)

2. Remove - removes the associated Kubernetes resource. This is effectively the same as kubectl delete. 

### Configurable Action Menu Items

Additional menu items can be added to the Application Table View using action config maps.  Config maps are a built-in Kubernetes resource type, used to store arbitrary configuration data in the Kubernetes config service.  Prism uses config maps to hold the configuration for configurable action menu items.  
See [action config maps](https://github.com/kappnav/design/blob/master/actions-config-maps.md) for a full definition of action config maps. 

# Prism Component Level View

The component level view shows the resources that comprise a specific application in the Kubernetes cluster in which Prism is running. 

## Common View Controls

The Prism component level view will have controls consistent with other list view pages in the ICP console, for example, as does the Deployment view: 

![common-page-top](https://github.com/kappnav/design/blob/master/images/common-screen-top.png)

## Component Table View 

Like other resource views in the ICP console, application components will be displayed using a tabular presentation: 

![component-table-view](https://github.com/kappnav/design/blob/master/images/component-table-view-2.png)

The resources displayed are those that match the label selector in the application resource ([e.g.stock trader](https://github.ibm.com/seed/prism/blob/636ffe405f2eff0d02755e2196a847ab99f2bf0d/samples/stock-trader.application.yaml#L8)) corresponding to a particular instance of this view. The set of resources displayed in the component table view may be of any Kubernetes kind. The following columns are displayed: 

- Status uses a color scheme to designate whether the application is running, stopped, etc. The rational for colors (instead of text) and color determination algorithm is described [here](https://github.com/kappnav/design/blob/master/status-determination.md).

  Note in the Component Level View, the Status indicator will provide a 'hover value' when the mouse pointer lingers on it, that displays the actual underlying text status value for the corresponding resource. The determination of what the text value is is explain [here](https://github.com/kappnav/design/blob/master/status-determination.md).

- Name is the component name. If the resource Kind is 'Application', it is a clickable link and takes takes the user to the [Prism Component Level View](#prism-component-level-view) for that application (i.e. nested application); otherwise it is a non-clickable link. 
- Kind is the resource kind and optional subkind.  See [Kind and Subkind](#kind-and-subkind) for further explanation.
- Namespace is the Kubernetes namespace in which the application resource exists. 
- Platform is the platform type and optional platform name on which the resource resides. See Platform Type and Name [Prism annotations](https://github.com/kappnav/design/blob/master/annotations.md) for further explanation.
- Action is a clickable field that opens a menu of selectable actions. See [Configurable Action Menu Items for Components](#configurable-action-menu-items-for-components) for explanation of the action items available on this menu.

### Create Application Button 

The standard header includes a Create button.  This button will open a dialog that enables the user to create a new application instance. 

The following screen shots show the layout of this dialog for field-driven input.  JSON mode is shown further down. 

**Enter General Values**

![](https://github.com/kappnav/design/blob/master/images/create-app-1.png)

**Enter Labels**

![](https://github.com/kappnav/design/blob/master/images/create-app-2.png)

**Enter Selectors**

![](https://github.com/kappnav/design/blob/master/images/create-app-3.png)

**Enter Kinds**

![](https://github.com/kappnav/design/blob/master/images/create-app-4.png)

**JSON Mode**

![](https://github.com/kappnav/design/blob/master/images/create-app-json.png)

## Prism Global Menu

The Prism top level page has a global menu positioned in the upper left corner.  This menu enables access to the following pages: 

1. Command Actions 
1. WAS ND Cell
1. Liberty Collectives 

![main](https://github.com/kappnav/design/blob/master/images/main-page-menu.png)

### Sortable Column Values 

Columns heads are clickable to toggle the sort between ascending and descending.  An up/down arrow (triangle, really), as is done in the rest of the ICP console, will be used to designate whether sort order is ascending (up arrow) or descending (down arrow).  e.g. 

![](https://github.com/kappnav/design/blob/master/images/clickable-column-head.png)

The sort rule for each column is:

- Status is sortable according to [status precedence](https://github.com/kappnav/design/blob/master/status-determination.md#prism-status-value-determination-algorithm-for-application-resource) order.
- Name column is sortable following the rules for a standard alphanumeric sort. 
  The default sort is ascending alphanumeric. 
- Kind[.Subkind] is sortable following the rules for a standard alphanumeric sort. 
  The default sort is ascending alphanumeric.
- Namespace is sortable following the rules for a standard alphanumeric sort. 
  The default sort is ascending alphanumeric.
- Platform[.Name] is sortable following the rules for a standard alphanumeric sort. 
  The default sort is ascending alphanumeric.
- Action column is not sortable. 

### Kind and Subkind 

The component view data includes fields kind and subkind.  The kind field comes from the standard kubernetes 'kind' field.  The subkind field is optional and comes from the kubernetes resource field **metadata.annotations.prism.subkind**.  When the prism.kind annotation is specified, the value displayed in the KIND column of the Component Table View is {kind}.{prism.subkind}; otherwise it is simply {kind}.  See [subkind Prism annotation](https://github.com/kappnav/design/blob/master/annotations.md) for additional information.

Note the Kind/Subkind field is clickable.  The link for this field comes from the action menu items for this component. The url action menu item named "detail" (if one exists) provides the URL for the kind/subkind field.  See [Configurable Action Menu Items for Components](https://github.com/kappnav/design/blob/master/UI-layout.md#configurable-action-menu-items-for-components) (below) for further details on action menu items.   


### Configurable Action Menu Items for Components

Additional menu items can be added to the Component Table View using action config maps.  Config maps are a built-in Kubernetes resource type, used to store arbitrary configuration data in the Kubernetes config service.  Prism uses config maps to hold the configuration for configurable action menu items.  
See [action config maps](https://github.com/kappnav/design/blob/master/actions-config-maps.md) for a full definition of action config maps. 
