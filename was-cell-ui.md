# WAS ND Cell View 

The WAS ND Cell View displays information about WebSphere Network Deployment cells that have been defined to Prism for navigational access. The WAS Cell View is launched from the [Prism Global Menu](https://github.com/kappnav/design/blob/master/UI-layout.md#prism-global-menu).

## Common View Controls 

The WAS ND Cell view will have controls consistent with other list view pages in the ICP console, for example, as does the Deployment view: 

![common-page-top](https://github.com/kappnav/design/blob/master/images/common-screen-top.png)

## Cell Table

The principle purpose of the Prism WAS ND cell view is to show a list [WAS ND cell resources](https://github.com/kappnav/design/blob/master/custom-resources.md#was-nd-cell). Like other resource views in the ICP console, WAS ND Cells will be displayed using a tabular presentation: 

![cell-table-view](https://github.com/kappnav/design/blob/master/images/cell-view.png)

Where:

- Status indicates current [status of WAS ND Cell](https://github.com/kappnav/design/blob/master/custom-resources.md#was-nd-cell).
- Name is the cell name. Clicking it takes the user to the [Cell Detail View](#was-nd-cell-detail-view).
- Console is the URL to access the WebSphere Administrative Console (aka WAS Admin Console) for the cell. It is a clickable field.  Clicking it takes you to the Admin Console.  You will be prompted to login if not already logged in. 
- Action is a clickable field that opens a menu of selectable actions. See [Standard Action Menu Items](#standard-action-menu-items) and [Configurable Action Menu Items](#configurable-action-menu-items) for explanation of the action items available on this menu.

### Sortable Column Values 

Columns heads are clickable to toggle the sort between ascending and descending.  An up/down arrow (triangle, really), as is done in the rest of the ICP console, will be used to designate whether sort order is ascending (up arrow) or descending (down arrow).  e.g. 

![](https://github.com/kappnav/design/blob/master/images/clickable-column-head.png)

The sort rule for each column is: 

- Status column is sortable following the rules for a standard alphanumeric sort. 
  The default sort is ascending alphanumeric. 
- Name column is sortable following the rules for a standard alphanumeric sort. 
  The default sort is ascending alphanumeric. 
- Console is sortable following the rules for a standard alphanumeric sort. 
  The default sort is ascending alphanumeric.
- Action column is not sortable. 

### Standard Action Menu Items

Like all other ICP views that display Kubernetes resources, the WAS ND Cell view page will include the following pre-defined action menu items: 

1. Edit 

The edit menu item, will launch a modal dialog to edit the WAS ND Cell's configuration, as is done elsewhere in the ICP console, as shown here with Deployment, as an example: 

![](https://github.com/kappnav/design/blob/master/images/resource-edit-modal.png)

2. Remove - removes the associated Kubernetes resource. This is effectively the same as kubectl delete. 

### Configurable Action Menu Items

Additional menu items can be added to the Cell Table View using action config maps.  Config maps are a built-in Kubernetes resource type, used to store arbitrary configuration data in the Kubernetes config service.  Prism uses config maps to hold the configuration for configurable action menu items.  
See [action config maps](https://github.com/kappnav/design/blob/master/actions-config-maps.md) for a full definition of action config maps. 


### Create WAS ND Cell Button 

The standard header includes a Create button.  This button will open a dialog that enables the user to create a new WAS ND Cell instance. This is not an actual WAS ND Cell, with nodes, node agents, and application servers, but rather a Kubernetes custom resource representing a WAS ND Cell. 

The following screen shots show the layout of this dialog for field-driven input.  JSON mode is shown further down. 

**Enter General Values**

![](https://github.com/kappnav/design/blob/master/images/create-cell-1.png)

**Enter Labels**

![](https://github.com/kappnav/design/blob/master/images/create-cell-2.png)

**Enter Network Info**

![](https://github.com/kappnav/design/blob/master/images/create-cell-3.png)

**Enter Security Info**

![](https://github.com/kappnav/design/blob/master/images/credentials.png)
![](https://github.com/kappnav/design/blob/master/images/credentials2.png)

**JSON Mode**

![](https://github.com/kappnav/design/blob/master/images/create-cell-json.png)

## WAS ND Cell Detail View

The WAS ND Cell detail view shows the [WAS Traditional Apps](https://github.com/kappnav/design/blob/master/custom-resources.md#was-traditional-app) deployed to that WAS ND Cell. 

### Common View Controls

The WAS ND cell detail level view will have controls consistent with other list view pages in the ICP console, for example, as does the Deployment view: 

![common-page-top](https://github.com/kappnav/design/blob/master/images/common-screen-top.png)

### Details and WAS Traditional Apps Table View 

The WAS-ND-Cell view will include a details section and, like other resource views in the ICP console that include collections, WAS Traditional Apps components will be displayed using a tabular presentation: 

![component-table-view](https://github.com/kappnav/design/blob/master/images/cell-app-view.png)

In the WAS-Traditional-Apps Table, the following columns are displayed: 

- Status indicates current [status of the WAS Traditional App](https://github.com/kappnav/design/blob/master/custom-resources.md#was-traditional-app-status-values).
- Name is the WAS Traditional App name. It is a clickable link and takes takes the user to the [WAS-Traditional-App detail view](https://github.com/kappnav/design/blob/master/was-cell-ui.md#was-traditional-app-detail-view).
- Labels shows the labels values assigned to a WAS Traditional App resource. 
- Action is a clickable field that opens a menu of selectable actions. See [Configurable Action Menu Items for Components](#configurable-action-menu-items-for-components) for explanation of the action items available on this menu.

### Sortable Column Values 

Columns heads are clickable to toggle the sort between ascending and descending.  An up/down arrow (triangle, really), as is done in the rest of the ICP console, will be used to designate whether sort order is ascending (up arrow) or descending (down arrow).  e.g. 

![](https://github.com/kappnav/design/blob/master/images/clickable-column-head.png)

The sort rule for each column is:

- Status is sortable following the rules for a standard alphanumeric sort. 
  The default sort is ascending alphanumeric. 
- Name column is sortable following the rules for a standard alphanumeric sort. 
  The default sort is ascending alphanumeric. 
- Labels is sortable following the rules for a standard alphanumeric sort. 
  The default sort is ascending alphanumeric.
- Action column is not sortable.  


### Configurable Action Menu Items for WAS Traditional Applications 

Additional menu items can be added to the WAS Traditional Applications Table View using action config maps.  Config maps are a built-in Kubernetes resource type, used to store arbitrary configuration data in the Kubernetes config service.  Prism uses config maps to hold the configuration for configurable action menu items.  
See [action config maps](https://github.com/kappnav/design/blob/master/actions-config-maps.md) for a full definition of action config maps. 

### WAS-Traditional-App Detail View

The following information is displayed for a WAS-Traditional-App instance: 

![twas](https://github.com/kappnav/design/blob/master/images/twas-app-detail-view.png)

Where: 

- name, namespace, labels, and targets are values that come directly from the resource instance.
- cell is a hyperlink to the [WAS-ND-Cell detail view](https://github.com/kappnav/design/blob/master/was-cell-ui.md#was-nd-cell-detail-view) that contains this WAS-Traditional-App instance. 
